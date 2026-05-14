from datetime import datetime, timedelta, timezone
from fastapi import HTTPException, status
from schema.userSchema import CustomerCreate, LoginRequest
from core.access_token import create_token
from core.security import verify_password, hash_password
from core.database import db
from core.access_token import get_current_user

async def login(user: LoginRequest):
    if user.email == "adminhaseeb@gmail.com" and user.password == "haseeb@1.in":
        admin_user = await db.users.find_one({"email": "adminhaseeb@gmail.com"})
        if not admin_user:
            admin_dict = {
                "name": "Admin",
                "email": "adminhaseeb@gmail.com",
                "passwrd": hash_password("haseeb@1.in"),
                "phone_number": "0000000000",
                "role": "admin",
                "created_at": datetime.now(timezone.utc),
                "is_active": True,
                "skills": [],
                "Wallet": 0.0,
                "rating": 0.0,
                "preferred_radius_km": 10,
            }
            res = await db.users.insert_one(admin_dict)
            admin_user = await db.users.find_one({"_id": res.inserted_id})
        
        token = create_token(data={"sub": str(admin_user['_id']), "role": "admin"}, expire=timedelta(minutes=30))
        return {"access_token": token, "token_type": "bearer"}

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
    
    
async def getname(user):
    return {"name": user['name']}

async def get_me(user):
    # Create a copy so we do not mutate the dictionary directly
    user_dict = dict(user)
    
    # Cast ObjectId to string so it can be serialized to JSON
    if '_id' in user_dict:
        user_dict['_id'] = str(user_dict['_id'])
        
    # Remove the sensitive password field
    user_dict.pop('passwrd', None)
    user_dict.pop('password', None)
    
    # Make sure times are serialized
    if 'created_at' in user_dict and isinstance(user_dict['created_at'], datetime):
        user_dict['created_at'] = user_dict['created_at'].isoformat()
    if 'updated_at' in user_dict and isinstance(user_dict['updated_at'], datetime):
        user_dict['updated_at'] = user_dict['updated_at'].isoformat()
        
    return user_dict


async def update_location(user, longitude: float, latitude: float):
    """
    Updates the user's location in the database.
    Called from the Flutter app when the user's GPS position is detected.
    Stores it as GeoJSON Point so MongoDB's $geoNear queries work correctly.
    """
    from bson import ObjectId

    try:
        user_id = user["_id"]

        # Validate coordinate ranges
        if not (-180 <= longitude <= 180):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Longitude must be between -180 and 180",
            )
        if not (-90 <= latitude <= 90):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Latitude must be between -90 and 90",
            )

        # GeoJSON format: [longitude, latitude]
        location_doc = {
            "type": "Point",
            "coordinates": [longitude, latitude],
        }

        await db.users.update_one(
            {"_id": user_id},
            {"$set": {"location": location_doc}},
        )

        return {"message": "Location updated successfully"}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Could not update location: {str(e)}",
        )