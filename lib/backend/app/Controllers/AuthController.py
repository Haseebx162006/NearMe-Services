from datetime import timedelta
from fastapi import HTTPException, status
from schema.userSchema import CustomerCreate, LoginRequest
from core.access_token import create_token
from core.security import verify_password, hash_password
from core.database import db

async def login(user: LoginRequest):
    #here i will authenticate the user and then create a token for them
    try:
        User = await db.users.find_one({'email': user.email})
        
        # checking if the user exsits in db or not 
        if User is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
        
        
        # Now checking here the password of the user is correct or not
        user_password = verify_password(user.password, User['password'])
        if not user_password:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
        
        # after verification now creating the token for the user 
        token =create_token(data={"sub": str(User['_id']), "role": User['role']}, expire=timedelta(minutes=30))
        
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    
    
    return {"access_token": token, "token_type": "bearer"}
    
async def signup(user: CustomerCreate):
    
    #here i will create a new user in the database and then create a token for them
    try:
        # checking if the user already exists in db or not
        User = await db.users.find_one({'email': user.email})
        if User is not None:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="User already exists")
        
        
        # now here hashing the password so that it does not get stored in plain text in the database
        hashed_password = hash_password(user.password)
        
        
        # here i am converting the data into to the dictionary so that it can be stored in a database 
        User_dict= user.dict()
        
        User_dict['password'] = hashed_password
        
        
        # now inserting itinot the db
        
        result = await db.users.insert_one(User_dict)
        
        token= await create_token(
            data={"sub": str(result.inserted_id), "role": user.role},
            expire=timedelta(minutes=30))
        
        return {"access_token": token, "token_type": "bearer"}
        
        
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Could not create user")