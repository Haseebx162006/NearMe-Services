from Service.PaymentService import PaymentService
from fastapi import Request

class PaymentController:
    def __init__(self):
        self.service = PaymentService()

    async def create_intent(self, order_id: str, amount: float):
        return await self.service.create_payment_intent(order_id, amount)

    async def handle_webhook(self, request: Request):
        payload = await request.body()
        sig_header = request.headers.get("stripe-signature")
        return await self.service.handle_stripe_webhook(payload, sig_header)

    async def release_payout(self, order_id: str):
        return await self.service.release_payment(order_id)
