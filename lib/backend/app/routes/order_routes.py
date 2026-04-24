from fastapi import APIRouter, Depends, HTTPException, status
from ..Controllers.OrderController import OrderController
from ..schema.OrderSchema import CreateOrderSchema
from ..core.checker import role_checker

router = APIRouter(
    prefix="/orders",
    tags=["Orders"]
)

controller = OrderController()

@router.post("/", status_code=status.HTTP_201_CREATED)
async def create_order(order_data: CreateOrderSchema, current_user: dict = Depends(role_checker(["customer", "freelancer"]))):
    # Depending on your business logic, you might want to ensure the customer_id in order_data 
    # matches the current_user["_id"] or let the controller handle it.
    return await controller.create_order(order_data.dict())

@router.get("/{order_id}")
async def get_order_by_id(order_id: str, current_user: dict = Depends(role_checker(["customer", "freelancer"]))):
    return await controller.get_order_by_id(order_id)
