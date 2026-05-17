from typing import Optional
from fastapi import APIRouter, Depends, status
from pydantic import BaseModel, Field
from Controllers.OrderController import OrderController
from schema.OrderSchema import CreateOrderSchema
from core.checker import role_checker

router = APIRouter(
    prefix="/orders",
    tags=["Orders"]
)

controller = OrderController()


class UpdateOrderStatusSchema(BaseModel):
    status: str


class SubmitReviewSchema(BaseModel):
    rating: int = Field(ge=1, le=5)
    comment: Optional[str] = None


@router.post("/", status_code=status.HTTP_201_CREATED)
async def create_order(
    order_data: CreateOrderSchema,
    current_user: dict = Depends(role_checker("customer")),
):
    return await controller.create_order(order_data.model_dump(), current_user)


@router.get("/freelancer/orders-for-freelancer")
async def get_orders_for_freelancer(
    current_user: dict = Depends(role_checker("freelancer")),
):
    return await controller.get_orders_as_freelancer(str(current_user["_id"]))


@router.get("/freelancer/my-accepted-orders")
async def get_my_accepted_orders(
    current_user: dict = Depends(role_checker("freelancer")),
):
    orders = await controller.get_orders_as_freelancer(str(current_user["_id"]))
    return [o for o in orders if o["status"] == "accepted"]


@router.get("/customer/my-orders")
async def get_my_orders_as_customer(
    current_user: dict = Depends(role_checker("customer")),
):
    return await controller.get_orders_as_customer(str(current_user["_id"]))


@router.get("/customer/pending-review")
async def customer_pending_review(
    current_user: dict = Depends(role_checker("customer")),
):
    has_pending = await controller.customer_has_pending_review(
        str(current_user["_id"])
    )
    return {"has_pending_review": has_pending}


@router.post("/{order_id}/review")
async def submit_order_review(
    order_id: str,
    review_data: SubmitReviewSchema,
    current_user: dict = Depends(role_checker("customer")),
):
    return await controller.submit_review(
        order_id,
        str(current_user["_id"]),
        review_data.rating,
        review_data.comment,
    )


@router.get("/{order_id}")
async def get_order_by_id(
    order_id: str,
    current_user: dict = Depends(role_checker(["customer", "freelancer"])),
):
    return await controller.get_order_by_id(order_id)


@router.patch("/{order_id}/status")
async def update_order_status(
    order_id: str,
    status_data: UpdateOrderStatusSchema,
    current_user: dict = Depends(role_checker(["freelancer", "customer"])),
):
    return await controller.update_order_status(order_id, status_data.status)
