from fastapi import APIRouter, Depends, Body

from Controllers.AuthController import (
    login as login_controller,
    signup as signup_controller,
    getname as getname_controller,
    get_me as get_me_controller,
    update_location as update_location_controller,
)
from core.access_token import get_current_user
from schema.userSchema import CustomerCreate, LoginRequest

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/login")
async def login(user: LoginRequest):

    return await login_controller(user)


@router.post("/signup")
async def signup(user: CustomerCreate):

    return await signup_controller(user)

@router.get("/getname")
async def getname(user = Depends(get_current_user)):
    return await getname_controller(user)

@router.get("/me")
async def get_me(user = Depends(get_current_user)):
    return await get_me_controller(user)

@router.patch("/update-location")
async def update_location(
    longitude: float = Body(...),
    latitude: float = Body(...),
    user = Depends(get_current_user),
):
    """Save the user's GPS coordinates to their profile."""
    return await update_location_controller(user, longitude, latitude)