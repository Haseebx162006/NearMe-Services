from typing import Optional
from fastapi import APIRouter, Depends, UploadFile, File, Form
from Controllers.DeliveryController import DeliveryController
from core.checker import role_checker

router = APIRouter(
    prefix="/delivery",
    tags=["Delivery"],
)

controller = DeliveryController()


@router.post("/{order_id}/submit")
async def submit_delivery(
    order_id: str,
    files: list[UploadFile] = File(...),
    message: str = Form(default=""),
    current_user: dict = Depends(role_checker("freelancer")),
):
    """Freelancer submits delivery files for an order."""
    freelancer_id = str(current_user.get("_id") or current_user.get("id"))
    return await controller.submit_delivery(order_id, freelancer_id, files, message)


@router.post("/{order_id}/accept")
async def accept_delivery(
    order_id: str,
    current_user: dict = Depends(role_checker("customer")),
):
    """Customer accepts the delivery and triggers payment release."""
    customer_id = str(current_user.get("_id") or current_user.get("id"))
    return await controller.accept_delivery(order_id, customer_id)


@router.post("/{order_id}/reject")
async def reject_delivery(
    order_id: str,
    reason: str = Form(default=""),
    current_user: dict = Depends(role_checker("customer")),
):
    """Customer rejects the delivery and sends it back for revision."""
    customer_id = str(current_user.get("_id") or current_user.get("id"))
    return await controller.reject_delivery(order_id, customer_id, reason)
