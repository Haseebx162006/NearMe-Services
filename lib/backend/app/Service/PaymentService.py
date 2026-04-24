import stripe
from core.config import settings
from core.database import db
from bson import ObjectId
from fastapi import HTTPException, status
from datetime import datetime
from utils.Constants import constant
from utils.Pyobject import validate_object_id

stripe.api_key = settings.STRIPE_SECRET_KEY

class PaymentService:
    def __init__(self):
        self.db = db

    async def create_payment_intent(self, order_id: str, amount: float):
        
        try:
            # Stripe expects amount in cents
            amount_in_cents = int(amount * 100)
            
            intent = stripe.PaymentIntent.create(
                amount=amount_in_cents,
                currency="usd",
                metadata={"orderId": order_id}
            )
            
            # Update order with payment intent ID (preliminary)
            await self.db.orders.update_one(
                {"_id": validate_object_id(order_id)},
                {"$set": {"stripe_payment_intent_id": intent.id, "payment_status": "pending"}}
            )
            
            return {"client_secret": intent.client_secret}
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    async def handle_stripe_webhook(self, payload, sig_header):
        """Step 2: Handle stripe-side success and update DB"""
        try:
            event = stripe.Webhook.construct_event(
                payload,sig_header, settings.STRIPE_WEBHOOK_SECRET
            )
        except stripe.error.SignatureVerificationError as e:
                raise HTTPException(status_code=400, detail="Invalid signature")
            
        if (event['type']== 'payment_intent.succeeded'):
            intent = event['data']['object']
            order_id = intent['metadata']['orderId']
            amount = intent['amount'] / 100.0  # Convert back to dollars
            
        if order_id and amount:
            await self._process_successful_payment(order_id, intent['id'], amount)
            
            return {"message": "Payment processed successfully"}
        
        
        
        
    async def _process_successful_payment(self, order_id_str: str, intent_id: str, amount: float):
        order_id = validate_object_id(order_id_str)
        order = await self.db.orders.find_one({"_id": order_id})
        
        if order:
            # Create Payment Record
            platform_fee = constant.PLATFORM_FEE
            freelancer_payout = amount - platform_fee
            
            payment_record = {
                "order_id": order_id,
                "customer_id": order.get("customer_id"),
                "freelancer_id": order.get("freelancer_id"),
                "stripe_payment_intent_id": intent_id,
                "amount": amount,
                "platform_fee": platform_fee,
                "freelancer_payout": freelancer_payout,
                "status": "held",
                "created_at": datetime.utcnow()
            }
            
            result = await self.db.payments.insert_one(payment_record)
            payment_id = result.inserted_id
            
            # Update Order with Link to Payment and Status
            await self.db.orders.update_one(
                {"_id": order_id},
                {
                    "$set": {
                        "payment_status": "held",
                        "stripe_payment_intent_id": intent_id,
                        "payment_id": payment_id
                    }
                }
            )

    async def release_payment(self, order_id_str: str):
        """Step 4: Admin releases held funds from linked Payment record"""
        order_id = validate_object_id(order_id_str)
        
        # 1. Fetch order record to get linked payment_id
        order = await self.db.orders.find_one({"_id": order_id})
        if not order or not order.get("payment_id"):
            raise HTTPException(status_code=404, detail="Payment record link not found for this order")
            
        payment_id = order["payment_id"]
        
        # 2. Fetch payment record
        payment = await self.db.payments.find_one({"_id": payment_id, "status": "held"})
        if not payment:
            raise HTTPException(status_code=404, detail="Held payment record not found")
        
        # 3. Update freelancer wallet
        freelancer_id = payment["freelancer_id"]
        payout_amount = payment["freelancer_payout"]
        
        await self.db.users.update_one(
            {"_id": freelancer_id},
            {"$inc": {"walletBalance": payout_amount}}
        )
        
        # 4. Mark payment as released
        await self.db.payments.update_one(
            {"_id": payment_id},
            {"$set": {"status": "released", "released_at": datetime.utcnow()}}
        )
        
        # 5. Mark order as released
        await self.db.orders.update_one(
            {"_id": order_id},
            {"$set": {"payment_status": "released"}}
        )
        
        return {"message": "Payment released to freelancer wallet"}

        
        await self.db.users.update_one(
            {"_id": freelancer_id},
            {"$inc": {"walletBalance": payout_amount}}
        )
        
        # 3. Mark payment as released
        await self.db.payments.update_one(
            {"_id": payment["_id"]},
            {"$set": {"status": "released", "released_at": datetime.utcnow()}}
        )
        
        # 4. Mark order as released
        await self.db.orders.update_one(
            {"_id": order_id},
            {"$set": {"payment_status": "released"}}
        )
        
        return {"message": "Payment released to freelancer wallet"}
