from fastapi import APIRouter, Depends, HTTPException, status
from Controllers.OrderController import OrderController
from schema.OrderSchema import CreateOrderSchema
from core.checker import role_checker

router = APIRouter(
    prefix="/orders",
    tags=["Orders"]
)

controller = OrderController()

@router.post("/", status_code=status.HTTP_201_CREATED)
async def create_order(order_data: CreateOrderSchema, current_user: dict = Depends(role_checker("customer"))):
    # The backend sets customer_id from the logged-in customer for safety.
    return await controller.create_order(order_data.model_dump(), current_user)

@router.get("/{order_id}")
async def get_order_by_id(order_id: str, current_user: dict = Depends(role_checker(["customer", "freelancer"]))):
    return await controller.get_order_by_id(order_id)

@router.get("/freelancer/orders-for-freelancer")
async def get_orders_for_freelancer(current_user: dict = Depends(role_checker("freelancer"))):
    """Get all orders where the current freelancer is offering services (pending or accepted)"""
    return await controller.get_orders_by_user(str(current_user["_id"]))

@router.get("/freelancer/my-accepted-orders")
async def get_my_accepted_orders(current_user: dict = Depends(role_checker("freelancer"))):
    """Get only accepted orders for the current freelancer"""
    return await controller.get_orders_by_user(str(current_user["_id"]))

from pydantic import BaseModel

class UpdateOrderStatusSchema(BaseModel):
    status: str

@router.patch("/{order_id}/status")
async def update_order_status(order_id: str, status_data: UpdateOrderStatusSchema, current_user: dict = Depends(role_checker(["freelancer", "customer"]))):
    return await controller.update_order_status(order_id, status_data.status)
async def get_my_accepted_orders(current_user: dict = Depends(role_checker("freelancer"))):
    """Get only accepted orders for the current freelancer"""
    return await controller.get_orders_by_user(str(current_user["_id"]))
