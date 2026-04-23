# this file contains a function that acts as a validator for checking the Role of the user
# it consists of 2 functions
# one is a outer function 
# 2nd is a inner function


# it involves the mechanism of depends


from fastapi import Depends, HTTPException, status
from .access_token import get_current_user

def role_checker(roles):
    allowed_roles = [roles] if isinstance(roles, str) else roles

    def get_user(user: dict = Depends(get_current_user)):
        if user.get("role") not in allowed_roles:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN,detail="Access denied")
        return user

    return get_user
