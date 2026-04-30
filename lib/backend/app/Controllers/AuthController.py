from datetime import datetime, timedelta, timezone
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
        # The password is stored as 'passwrd' in the database
        stored_password = User.get('passwrd') or User.get('password')
        if not stored_password:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
        
        user_password = verify_password(user.password, stored_password)
        if not user_password:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
        
        # after verification now creating the token for the user 
        token = create_token(data={"sub": str(User['_id']), "role": User['role']}, expire=timedelta(minutes=30))
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    
    
    return {"access_token": token, "token_type": "bearer"}
    
async def signup(user: CustomerCreate):
    
    #here i will create a new user in the database and then create a token for them
    try:
        # checking if the user already exists in db or not
        User_exists = await db.users.find_one({'email': user.email})
        if User_exists is not None:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="User already exists")
        
        
        # now here hashing the password so that it does not get stored in plain text in the database
        hashed_password = hash_password(user.password)
        
        
        # Convert Pydantic model to dict (model_dump is the Pydantic v2 way)
        # exclude_none=True removes any None fields (like location) so they
        # don't get inserted into MongoDB and break the 2dsphere index
        User_dict = user.model_dump(exclude_none=True)
        
        # Pydantic schema uses 'password', but Database model uses 'passwrd'
        User_dict['passwrd'] = hashed_password
        if 'password' in User_dict:
            del User_dict['password']
        
        # Add default timestamps (using timezone-aware UTC)
        User_dict['created_at'] = datetime.now(timezone.utc)
        User_dict['is_active'] = True
        
        # now inserting into the db
        result = await db.users.insert_one(User_dict)
        
        token = create_token(
            data={"sub": str(result.inserted_id), "role": user.role},
            expire=timedelta(minutes=30))
        
        return {"access_token": token, "token_type": "bearer"}
        
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Signup Error: {e}")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Could not create user: {str(e)}")