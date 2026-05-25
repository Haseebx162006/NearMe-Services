from fastapi import APIRouter, Depends, status, Request, Body
from Controllers.PaymentController import PaymentController
from core.checker import role_checker

router = APIRouter(prefix="/payments", tags=["Payments"])
controller = PaymentController()


@router.post("/create-intent")
async def create_payment_intent(
    order_id: str = Body(..., embed=True),
    current_user: dict = Depends(role_checker(["customer", "freelancer"]))
):
    """
    Initiate a payment for an order.
    Fix #2: Amount is no longer accepted from the client.
    The service reads the amount directly from the order in the DB.
    """
    return await controller.create_intent(order_id)


@router.post("/webhook/stripe")
async def stripe_webhook(request: Request):
    """Public webhook for Stripe events"""
    return await controller.handle_webhook(request)


@router.post("/connect/create-account")
async def create_connected_account(
    current_user: dict = Depends(role_checker(["freelancer"]))
):
    """Create Stripe Connected Account for Freelancer"""
    freelancer_id = current_user.get("_id") or current_user.get("id")
    return await controller.create_connected_account(str(freelancer_id))


@router.post("/connect/onboarding-link")
async def get_onboarding_link(
    refresh_url: str = Body(..., embed=True),
    return_url: str = Body(..., embed=True),
    current_user: dict = Depends(role_checker(["freelancer"]))
):
    """Get Stripe Onboarding Link for Freelancer"""
    freelancer_id = current_user.get("_id") or current_user.get("id")
    return await controller.get_onboarding_link(str(freelancer_id), refresh_url, return_url)
