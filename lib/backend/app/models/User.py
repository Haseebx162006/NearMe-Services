from pydantic import BaseModel, EmailStr , Field
from typing import Optional, List
from datetime import datetime


class Location(BaseModel):
    type : str = "Point"
    coordinates : List[float]
    
    
class User(BaseModel):
    id: str
    name:str
    email:EmailStr
    passwrd: str
    phone_number:str
    role: str
    
    profile_picture: Optional[str]
    profile_bio: Optional[str]
    
    location: Location
    
    skills: Optional[List[str]] = Field(default_factory=list)
    Wallet: Optional[float] = 0.0
    rating: Optional[float] = 0.0
    
    preferred_radius_km: Optional[int] = 10


    is_active: bool = True
    suspension_remark: Optional[str] = None
    
    created_at : datetime = Field(default_factory=datetime.utcnow)
    updated_at : Optional[datetime] = None
    
    
    
    
    

