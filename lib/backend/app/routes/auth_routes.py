from fastapi import APIRouter

from Controllers.AuthController import login as login_controller, signup as signup_controller
from schema.userSchema import CustomerCreate, LoginRequest

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/login")
async def login(user: LoginRequest):

    return await login_controller(user)


@router.post("/signup")
async def signup(user: CustomerCreate):

    return await signup_controller(user)
