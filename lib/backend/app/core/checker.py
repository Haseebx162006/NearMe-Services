# this file contains a function that acts as a validator for checking the Role of the user
# it consists of 2 functions
# one is a outer function 
# 2nd is a inner function


# it involves the mechanism of depends


from fastapi import Depends, HTTPException, status
from typing import Iterable, Union
from .access_token import get_current_user

def _normalize_roles(roles: Union[str, Iterable[str]]) -> set:
    if isinstance(roles, str):
        normalized_roles = {roles}
    else:
        normalized_roles = {role for role in roles if role}

    if not normalized_roles:
        raise ValueError("roles must contain at least one role")

    return normalized_roles


def ensure_role(user: dict, roles: Union[str, Iterable[str]]) -> dict:
    allowed_roles = _normalize_roles(roles)
    user_role = user.get("role") if isinstance(user, dict) else None

    if user_role not in allowed_roles:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")

    return user


def role_checker(roles: Union[str, Iterable[str]]):
    allowed_roles = _normalize_roles(roles)

    def get_user(user: dict = Depends(get_current_user)):
        if user.get("role") not in allowed_roles:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")
        return user

    return get_user
