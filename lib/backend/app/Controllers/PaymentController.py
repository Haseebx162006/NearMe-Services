from Service.PaymentService import PaymentService
from fastapi import Request


class PaymentController:
    def __init__(self):
        self.service = PaymentService()

    async def create_intent(self, order_id: str):
        """Fix #2: No longer accepts amount from client."""
        return await self.service.create_payment_intent(order_id)

    async def handle_webhook(self, request: Request):
        payload = await request.body()
        sig_header = request.headers.get("stripe-signature")
        return await self.service.handle_stripe_webhook(payload, sig_header)
        
    async def create_connected_account(self, freelancer_id: str):
        return await self.service.create_connected_account(freelancer_id)
        
    async def get_onboarding_link(self, freelancer_id: str, refresh_url: str, return_url: str):
        return await self.service.get_onboarding_link(freelancer_id, refresh_url, return_url)
