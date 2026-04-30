from motor.motor_asyncio import AsyncIOMotorDatabase
from pydantic import BaseModel, EmailStr, Field, field_validator
from pymongo import GEOSPHERE, IndexModel
from typing import Optional, List
from datetime import datetime


class Location(BaseModel):
    type : str = "Point"
    coordinates : List[float]

    @field_validator("coordinates")
    @classmethod
    def validate_coordinates(cls, value: List[float]) -> List[float]:
        if len(value) != 2:
            raise ValueError("Location coordinates must be [longitude, latitude]")

        longitude, latitude = value
        if longitude < -180 or longitude > 180:
            raise ValueError("Longitude must be between -180 and 180")
        if latitude < -90 or latitude > 90:
            raise ValueError("Latitude must be between -90 and 90")
        return value
    
    
class User(BaseModel):
    id: Optional[str] = Field(alias="_id")
    name:str
    email:EmailStr
    passwrd: str
    phone_number:str
    role: str
    
    profile_picture: Optional[str]
    profile_bio: Optional[str]
    
    location: Optional[Location] = None
    
    skills: Optional[List[str]] = Field(default_factory=list)
    Wallet: Optional[float] = 0.0
    rating: Optional[float] = 0.0
    
    preferred_radius_km: Optional[int] = 10


    is_active: bool = True
    suspension_remark: Optional[str] = None
    
    created_at : datetime = Field(default_factory=datetime.utcnow)
    updated_at : Optional[datetime] = None


USER_INDEXES = [
   IndexModel(
       [("location", GEOSPHERE)],
       name="idx_users_location_2dsphere",
       # Note: partial_filter_expression is NOT supported for 2dsphere indexes.
       # We rely on application-level validation to ensure GeoJSON correctness.
   ),
   IndexModel([("role", 1), ("is_active", 1)], name="idx_users_role_active")
]


async def ensure_user_indexes(database: AsyncIOMotorDatabase) -> None:
    try:
        await database.users.create_indexes(USER_INDEXES)
    except Exception as e:
        # If there's a conflict, drop the old index and recreate it
        if "IndexKeySpecsConflict" in str(e) or "already exists with different options" in str(e):
            await database.users.drop_index("idx_users_location_2dsphere")
            await database.users.create_indexes(USER_INDEXES)
        else:
            raise e
    
    
    
    
    

