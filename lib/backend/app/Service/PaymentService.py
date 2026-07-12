import stripe
from core.config import settings
from core.database import db
from fastapi import HTTPException
from datetime import datetime, timezone
from utils.Constants import constant
from utils.Pyobject import validate_object_id

stripe.api_key = settings.STRIPE_SECRET_KEY


class PaymentService:

    def __init__(self):
        self.db = db


    async def create_payment_intent(self, order_id: str):
    
        order = await self.db.orders.find_one(
            {"_id": validate_object_id(order_id)}
        )

        if not order:
            raise HTTPException(status_code=404, detail="Order not found")

        if order.get("status") in ("cancelled", "completed"):
            raise HTTPException(status_code=400, detail="Order already closed")

        
        existing_pi_id = order.get("stripe_payment_intent_id")
        if existing_pi_id:
            try:
                existing = stripe.PaymentIntent.retrieve(existing_pi_id)
                if existing.status in (
                    "requires_payment_method",
                    "requires_confirmation",
                    "requires_action",
                ):
                    # Reuse the existing intent
                    return {"client_secret": existing.client_secret}
                elif existing.status == "succeeded":
                    raise HTTPException(
                        status_code=400,
                        detail="Payment already completed for this order",
                    )
            except stripe.error.StripeError:
                pass  # Intent may have expired — create a new one below

        freelancer = await self.db.users.find_one(
            {"_id": validate_object_id(order.get("freelancer_id"))}
        )

        stripe_account_id = freelancer.get("stripe_account_id") if freelancer else None

        if not stripe_account_id:
            raise HTTPException(
                status_code=400,
                detail="Freelancer has no Stripe account connected",
            )

        try:
            account = stripe.Account.retrieve(stripe_account_id)
            if not account.charges_enabled:
                raise HTTPException(
                    status_code=400,
                    detail="Freelancer's Stripe account is not fully set up. "
                           "Please complete onboarding first.",
                )
        except stripe.error.StripeError as e:
            raise HTTPException(
                status_code=500,
                detail=f"Failed to verify freelancer Stripe account: {str(e)}",
            )

        amount = order["amount"]
        amount_in_cents = int(amount * 100)

  
        fee_percent = constant.PLATFORM_FEE / 100  # Constants stores 4 → 0.04
        application_fee = int(amount_in_cents * fee_percent)

        
        intent = stripe.PaymentIntent.create(
            amount=amount_in_cents,
            currency="usd",
            metadata={
                "orderId": str(order_id),
                "freelancerStripeAccountId": stripe_account_id,
                "applicationFee": str(application_fee),
            },
            idempotency_key=f"order_{order_id}",
        )

        await self.db.orders.update_one(
            {"_id": validate_object_id(order_id)},
            {
                "$set": {
                    "stripe_payment_intent_id": intent.id,
                    "payment_status": "pending",
                    "updated_at": datetime.now(timezone.utc),
                }
            },
        )

        return {"client_secret": intent.client_secret}

   
    async def handle_stripe_webhook(self, payload, sig_header):
       
        try:
            event = stripe.Webhook.construct_event(
                payload,
                sig_header,
                settings.STRIPE_WEBHOOK_SECRET,
            )
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid webhook")

        if event["type"] != "payment_intent.succeeded":
            return {"message": "ignored"}

        intent = event["data"]["object"]
        order_id = intent.get("metadata", {}).get("orderId")

    
        if not order_id:
            return {"message": "acknowledged, missing orderId"}

        order = await self.db.orders.find_one(
            {"_id": validate_object_id(order_id)}
        )

        if not order:
            return {"message": "acknowledged, order not found"}

        
        if order.get("payment_status") == "held":
            return {"message": "already processed"}

        await self.db.orders.update_one(
            {"_id": validate_object_id(order_id)},
            {
                "$set": {
                    "payment_status": "held",
                    "updated_at": datetime.now(timezone.utc),
                }
            },
        )

        return {"message": "Payment confirmed"}


    async def create_connected_account(self, freelancer_id: str):

        freelancer = await self.db.users.find_one(
            {"_id": validate_object_id(freelancer_id)}
        )

        if not freelancer:
            raise HTTPException(status_code=404, detail="Freelancer not found")

        if freelancer.get("stripe_account_id"):
            return {"stripe_account_id": freelancer["stripe_account_id"]}

        try:
            account = stripe.Account.create(
                type="express",
                country="US",
                email=freelancer.get("email"),
                capabilities={
                    "card_payments": {"requested": True},
                    "transfers": {"requested": True},
                },
            )
        except stripe.error.StripeError as e:
            raise HTTPException(
                status_code=500,
                detail=f"Failed to create Stripe account: {str(e)}",
            )

        await self.db.users.update_one(
            {"_id": validate_object_id(freelancer_id)},
            {"$set": {"stripe_account_id": account.id}},
        )

        return {"stripe_account_id": account.id}

   
    async def get_onboarding_link(self, freelancer_id: str, refresh_url: str, return_url: str):

        freelancer = await self.db.users.find_one(
            {"_id": validate_object_id(freelancer_id)}
        )

        if not freelancer or not freelancer.get("stripe_account_id"):
            raise HTTPException(status_code=400, detail="Stripe account missing")

        link = stripe.AccountLink.create(
            account=freelancer["stripe_account_id"],
            refresh_url=refresh_url,
            return_url=return_url,
            type="account_onboarding",
        )

        return {"url": link.url}

    async def release_payment(self, order_id: str):
        
        order_oid = validate_object_id(order_id)
        order = await self.db.orders.find_one({"_id": order_oid})

        if not order:
            raise HTTPException(status_code=404, detail="Order not found")

   
        if order.get("status") == "disputed":
            raise HTTPException(
                status_code=400,
                detail="Cannot release payment during an active dispute",
            )

        if order.get("payment_status") == "released":
            raise HTTPException(status_code=400, detail="Already released")

        payment_intent_id = order.get("stripe_payment_intent_id")
        if not payment_intent_id:
            # If there's no payment intent (e.g. during testing/direct orders),
            # mark the local payment status as released so the order can be completed.
            await self.db.orders.update_one(
                {"_id": order_oid},
                {
                    "$set": {
                        "payment_status": "released",
                        "updated_at": datetime.now(timezone.utc),
                    }
                },
            )
            return {"message": "No payment intent found, marked as released locally"}

    
        try:
            intent = stripe.PaymentIntent.retrieve(payment_intent_id)
            if intent.status != "succeeded":
                raise HTTPException(
                    status_code=400,
                    detail=f"Payment intent status is '{intent.status}', cannot release",
                )

            # Get the charge ID from the PaymentIntent
            charge_id = intent.latest_charge

            # Determine freelancer's Stripe account
            freelancer = await self.db.users.find_one(
                {"_id": validate_object_id(order.get("freelancer_id"))}
            )
            stripe_account_id = freelancer.get("stripe_account_id") if freelancer else None

            if not stripe_account_id:
                raise HTTPException(
                    status_code=400,
                    detail="Freelancer has no Stripe account for payout",
                )

            # Calculate transfer amount (total - platform fee)
            amount_in_cents = int(order["amount"] * 100)
            fee_percent = constant.PLATFORM_FEE / 100
            platform_fee = int(amount_in_cents * fee_percent)
            transfer_amount = amount_in_cents - platform_fee

            # Create the actual Stripe Transfer
            stripe.Transfer.create(
                amount=transfer_amount,
                currency="usd",
                destination=stripe_account_id,
                source_transaction=charge_id,
                metadata={"orderId": str(order_id)},
            )

        except stripe.error.StripeError as e:
            raise HTTPException(
                status_code=500,
                detail=f"Stripe transfer failed: {str(e)}",
            )

        # Atomic update to prevent double-release (Fix #16)
        result = await self.db.orders.find_one_and_update(
            {
                "_id": order_oid,
                "payment_status": {"$ne": "released"},
            },
            {
                "$set": {
                    "payment_status": "released",
                    "updated_at": datetime.now(timezone.utc),
                }
            },
        )

        if not result:
            raise HTTPException(status_code=409, detail="Payment already released (concurrent request)")

        return {"message": "Payment released successfully"}

 
    async def refund_payment(self, order_id: str):
        """
        Refund the payment back to the customer via Stripe.
        Fix #6: Proper try/except around Stripe call.
        """
        order = await self.db.orders.find_one(
            {"_id": validate_object_id(order_id)}
        )

        if not order:
            raise HTTPException(status_code=404, detail="Order not found")

        if order.get("payment_status") == "refunded":
            raise HTTPException(status_code=400, detail="Already refunded")

        if order.get("payment_status") == "released":
            raise HTTPException(
                status_code=400,
                detail="Cannot refund — payment already released to freelancer",
            )

        payment_intent_id = order.get("stripe_payment_intent_id")

        if not payment_intent_id:
            raise HTTPException(status_code=400, detail="Missing payment intent")

       
        try:
            stripe.Refund.create(payment_intent=payment_intent_id)
        except stripe.error.StripeError as e:
            raise HTTPException(
                status_code=500,
                detail=f"Stripe refund failed: {str(e)}",
            )

        await self.db.orders.update_one(
            {"_id": validate_object_id(order_id)},
            {
                "$set": {
                    "payment_status": "refunded",
                    "status": "cancelled",
                    "updated_at": datetime.now(timezone.utc),
                }
            },
        )

        return {"message": "Refund successful"}