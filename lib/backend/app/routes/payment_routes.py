from fastapi import APIRouter, Depends, status, Request, Body
from fastapi.responses import HTMLResponse
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


_SUCCESS_HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Stripe Setup Complete</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            text-align: center;
            padding: 20px;
        }
        .card {
            background: rgba(255,255,255,0.15);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 40px 32px;
            max-width: 400px;
            width: 100%;
        }
        .icon { font-size: 64px; margin-bottom: 16px; }
        h1 { font-size: 22px; margin-bottom: 8px; }
        p { font-size: 15px; opacity: 0.9; line-height: 1.5; }
    </style>
</head>
<body>
    <div class="card">
        <div class="icon">✅</div>
        <h1>Stripe Setup Complete!</h1>
        <p>Your payment account has been set up successfully. You can close this page and return to the <strong>NearMe</strong> app.</p>
    </div>
</body>
</html>
"""

_REFRESH_HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Session Expired</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: #fff;
            text-align: center;
            padding: 20px;
        }
        .card {
            background: rgba(255,255,255,0.15);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 40px 32px;
            max-width: 400px;
            width: 100%;
        }
        .icon { font-size: 64px; margin-bottom: 16px; }
        h1 { font-size: 22px; margin-bottom: 8px; }
        p { font-size: 15px; opacity: 0.9; line-height: 1.5; }
    </style>
</head>
<body>
    <div class="card">
        <div class="icon">🔄</div>
        <h1>Session Expired</h1>
        <p>Your onboarding session has expired. Please close this page, return to the <strong>NearMe</strong> app, and tap <strong>Connect Stripe</strong> again.</p>
    </div>
</body>
</html>
"""


@router.get("/connect/return")
async def stripe_connect_return():
    """Redirect page after successful Stripe onboarding"""
    return HTMLResponse(content=_SUCCESS_HTML)


@router.get("/connect/refresh")
async def stripe_connect_refresh():
    """Redirect page when Stripe onboarding link expires"""
    return HTMLResponse(content=_REFRESH_HTML)


@router.post("/confirm")
async def confirm_payment(
    order_id: str = Body(..., embed=True),
    current_user: dict = Depends(role_checker(["customer", "freelancer"]))
):
    """Confirm Stripe payment for an order and mark as held"""
    return await controller.confirm_payment(order_id)

