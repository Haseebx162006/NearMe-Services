from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime
class Location:
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
    
    skills: Optional[List[str]] = []
    Wallet: Optional[float] = 0.0
    rating: Optional[float] = 0.0
    
    preferred_radius_km: Optional[int] = 10


    is_active: bool = True
    suspension_remark: Optional[str] = None
    
    created_at : datetime = datetime.utcnow()
    
    
    
    
    

