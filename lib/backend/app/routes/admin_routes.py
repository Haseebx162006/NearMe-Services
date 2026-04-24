from fastapi import APIRouter, Depends, status, Body
from Controllers.AdminController import AdminController
from core.checker import role_checker

router = APIRouter(
    prefix="/admin",
    tags=["Admin"]
)

controller = AdminController()

@router.get("/users")
async def get_all_users(current_user: dict = Depends(role_checker("admin"))):
    return await controller.get_all_users()

@router.post("/users/{user_id}/suspend")
async def suspend_user(
    user_id: str, 
    remark: str = Body(..., embed=True), 
    current_user: dict = Depends(role_checker("admin"))
):
    return await controller.suspend_account(user_id, remark)

@router.post("/users/{user_id}/reactivate")
async def reactivate_user(user_id: str, current_user: dict = Depends(role_checker("admin"))):
    return await controller.reactivate_account(user_id)
