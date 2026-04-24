from fastapi import APIRouter, Depends, status, Request, Body
from Controllers.PaymentController import PaymentController
from core.checker import role_checker

router = APIRouter(prefix="/payments", tags=["Payments"])
controller = PaymentController()

@router.post("/create-intent")
async def create_payment_intent(
    order_id: str = Body(..., embed=True),
    amount: float = Body(..., embed=True),
    current_user: dict = Depends(role_checker(["customer", "freelancer"]))
):
    """Initiate a payment for an order"""
    return await controller.create_intent(order_id, amount)

@router.post("/webhook/stripe")
async def stripe_webhook(request: Request):
    """Public webhook for Stripe events"""
    return await controller.handle_webhook(request)

@router.patch("/admin/orders/{order_id}/release-payment")
async def release_payout(
    order_id: str,
    current_user: dict = Depends(role_checker("admin"))
):
    """Admin-only: Release escrowed funds to freelancer"""
    return await controller.release_payout(order_id)
