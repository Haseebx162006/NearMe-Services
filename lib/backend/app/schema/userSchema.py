from typing import List, Optional

from models.User import Location
from pydantic import BaseModel, EmailStr

class UserBase(BaseModel):
    name: str
    email: EmailStr
    phone_number: str
    role: str
    profile_picture: Optional[str] = None
    profile_bio: Optional[str] = None
    location: Location
    
class CustomerCreate(UserBase):
    password: str


class LoginRequest(BaseModel):
    email: EmailStr
    password: str
    
class UserUpdate(BaseModel):    
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone_number: Optional[str] = None
    profile_picture: Optional[str] = None
    profile_bio: Optional[str] = None
    location: Optional[Location] = None
    

class FreelancerProfile(BaseModel):
    skills: Optional[List[str]] = []
    preferred_radius_km: Optional[int] = 10
    suspension_remark: Optional[str] = None 
    
    
class UserResponse(UserBase):
    id: str

    skills: Optional[List[str]] = []
    preferred_radius_km: Optional[int] = 10
    suspension_remark: Optional[str] = None