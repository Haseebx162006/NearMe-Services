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
       # Skip malformed legacy location docs while building geo index.
       partialExpression={
           "location":{
               "$type":"Point",
               'location.coordinates.0':{"$type":"number"},
               'location.coordinates.1':{"$type":"number"}
           }
       }
   ),
   IndexModel([("role", 1), ("is_active", 1)], name="idx_users_role_active")
]


async def ensure_user_indexes(database: AsyncIOMotorDatabase) -> None:
    await database.users.create_indexes(USER_INDEXES)
    
    
    
    
    

