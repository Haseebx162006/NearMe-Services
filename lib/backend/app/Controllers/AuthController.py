from datetime import datetime, timedelta, timezone
from fastapi import HTTPException, status
from schema.userSchema import CustomerCreate, LoginRequest
from core.access_token import create_token
from core.security import verify_password, hash_password
from core.database import db
from core.access_token import get_current_user

async def login(user: LoginRequest):
    # Admin login hardcodes
    admin_credentials = {
        "adminhaseeb@gmail.com": "haseeb@1.in",
        "admin1@gmail.com": "haseeb@1"
    }

    # Case-insensitive email check for hardcoded admins
    email_lower = user.email.lower().strip()
    if email_lower in admin_credentials and user.password == admin_credentials[email_lower]:
        admin_user = await db.users.find_one({"email": email_lower})
        
        if not admin_user:
            # Create the admin record if it doesn't exist
            admin_dict = {
                "name": "Admin",
                "email": email_lower,
                "passwrd": hash_password(user.password),
                "phone_number": "03249540797",
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
        elif admin_user.get("role") != "admin":
            # Force upgrade to admin if they were created as customer/freelancer by mistake
            await db.users.update_one({"_id": admin_user["_id"]}, {"$set": {"role": "admin"}})
            admin_user["role"] = "admin"
        
        # Double check the role is set to admin in our local dict before creating the token
        user_id_str = str(admin_user['_id'])
        token = create_token(data={"sub": user_id_str, "role": "admin"}, expire=timedelta(minutes=60))
        return {"access_token": token, "token_type": "bearer"}

    # Standard authentication flow
    try:
        User = await db.users.find_one({'email': email_lower})
        
        if User is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
        
        # The password is stored as 'passwrd' in the database
        stored_password = User.get('passwrd') or User.get('password')
        if not stored_password:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
        
        user_password = verify_password(user.password, stored_password)
        if not user_password:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
        
        # Create token with the role stored in the database
        token = create_token(data={"sub": str(User['_id']), "role": User.get('role', 'customer')}, expire=timedelta(minutes=60))
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Login Error: {e}")
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Authentication failed")
    
    return {"access_token": token, "token_type": "bearer"}
    
async def signup(user: CustomerCreate):
    try:
        # Check if the user already exists
        User_exists = await db.users.find_one({'email': user.email.lower().strip()})
        if User_exists is not None:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="User already exists")
        
        hashed_password = hash_password(user.password)
        
        User_dict = user.model_dump(exclude_none=True)
        User_dict['email'] = User_dict['email'].lower().strip()
        User_dict['passwrd'] = hashed_password
        if 'password' in User_dict:
            del User_dict['password']
        
        User_dict['created_at'] = datetime.now(timezone.utc)
        User_dict['is_active'] = True
        
        # Default empty fields for consistency
        User_dict.setdefault('skills', [])
        User_dict.setdefault('Wallet', 0.0)
        User_dict.setdefault('rating', 0.0)
        User_dict.setdefault('preferred_radius_km', 10)
        
        result = await db.users.insert_one(User_dict)
        
        token = create_token(
            data={"sub": str(result.inserted_id), "role": user.role},
            expire=timedelta(minutes=60))
        
        return {"access_token": token, "token_type": "bearer"}
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Signup Error: {e}")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Could not create account")
    
async def getname(user):
    return {"name": user.get('name', 'User')}

async def get_me(user):
    user_dict = dict(user)
    if '_id' in user_dict:
        user_dict['_id'] = str(user_dict['_id'])
        
    user_dict.pop('passwrd', None)
    user_dict.pop('password', None)
    
    if 'created_at' in user_dict and isinstance(user_dict['created_at'], datetime):
        user_dict['created_at'] = user_dict['created_at'].isoformat()
    if 'updated_at' in user_dict and isinstance(user_dict['updated_at'], datetime):
        user_dict['updated_at'] = user_dict['updated_at'].isoformat()
        
    return user_dict

async def update_location(user, longitude: float, latitude: float):
    from bson import ObjectId
    try:
        user_id = user["_id"]
        if not (-180 <= longitude <= 180) or not (-90 <= latitude <= 90):
            raise HTTPException(status_code=400, detail="Invalid coordinates")

        location_doc = {
            "type": "Point",
            "coordinates": [longitude, latitude],
        }

        await db.users.update_one(
            {"_id": user_id},
            {"$set": {"location": location_doc}},
        )
        return {"message": "Location updated"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))