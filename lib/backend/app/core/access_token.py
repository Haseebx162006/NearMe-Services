from datetime import timedelta
from datetime import datetime
from typing import List 
from jose import jwt, JWTError

from .config import settings

from fastapi.security import OAuth2PasswordBearer

from fastapi import Depends, HTTPException, status

from .database import db

oauth2_scheme= OAuth2PasswordBearer(tokenUrl="login")

def create_token(data: dict, expire:timedelta):
    try:
        
        to_enocode = data.copy()
        
        if expire:
            exp= expire + datetime.utcnow()
        else:
            exp= timedelta(minutes=30)+ datetime.utcnow()
            
        
        to_enocode.update({'exp': exp})
        
        
        encoded_jwt = jwt.encode(to_enocode, key=settings.SECRET_KEY,algorithm=settings.ALGORITHM,)
        
        return encoded_jwt
        
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Could not create access token")
    

    
    
    

def get_current_user(token: str = Depends(oauth2_scheme)):
    credntial_exception = HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Could not validate credentials")
    
    try:
        payload = jwt.decode(token, key=settings.SECRET_KEY,algorithms=[settings.ALGORITHM])
        
        if payload is None:
            raise credntial_exception
        
        user_id: str = payload.get("sub")
        role: str = payload.get("role")
        if user_id is None:
            raise credntial_exception
        
    except JWTError:
        raise credntial_exception
    
    user = db.find_one({'_id': user_id})
    
    
    if user is None:
        raise credntial_exception
    
    
    
    
    return user