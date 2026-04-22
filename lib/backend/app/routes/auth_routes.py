from datetime import timedelta
from fastapi import HTTPException, status

from fastapi import APIRouter
from ..schema.userSchema import CustomerCreate
from ..core.access_token import create_token
router= APIRouter()


@router.get("/login")

def login(user: CustomerCreate):
    #here i will authenticate the user and then create a token for them
    
    
    
    try:
        token = create_token(data=CustomerCreate.dict(), expire=timedelta(minutes=30))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")