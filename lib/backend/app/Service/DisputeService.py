import stripe
from fastapi import HTTPException
from core.database import db
from core.config import settings
from utils.Pyobject import validate_object_id
from Service.PaymentService import PaymentService
from datetime import datetime, timezone

stripe.api_key = settings.STRIPE_SECRET_KEY


class DisputeService:
    """
    Handles the dispute lifecycle:
    - Customer opens a dispute on a delivered order
    - Admin resolves the dispute (freelancer wins or customer wins)
    - Admin can list all open/resolved disputes
    """

    def __init__(self):
        self.db = db
        self.payment_service = PaymentService()

    async def create_dispute(self, order_id: str, customer_id: str, reason: str):
        """
        Customer opens a dispute on an order.
        Only allowed on orders with status 'delivered'.

        Fix #8:  Atomic status transition (prevents race with accept_delivery).
        Fix #16: Uses find_one_and_update.
        """
        order_oid = validate_object_id(order_id)
        order = await self.db.orders.find_one({"_id": order_oid})

        if not order:
            raise HTTPException(status_code=404, detail="Order not found")

        # --- Ownership check ---
        if str(order.get("customer_id")) != customer_id:
            raise HTTPException(status_code=403, detail="Not your order")

        # Only delivered orders can be disputed
        if order.get("status") != "delivered":
            raise HTTPException(
                status_code=400,
                detail=f"Cannot dispute an order with status '{order.get('status')}'. "
                       f"Only delivered orders can be disputed.",
            )

        # Prevent duplicate dispute
        if order.get("dispute_status") == "open":
            raise HTTPException(status_code=400, detail="Dispute already open")

        # --- Fix #8: Atomic status transition ---
        result = await self.db.orders.find_one_and_update(
            {
                "_id": order_oid,
                "status": "delivered",
                "dispute_status": {"$ne": "open"},
            },
            {
                "$set": {
                    "status": "disputed",
                    "dispute_status": "open",
                    "dispute_reason": reason,
                    "updated_at": datetime.now(timezone.utc),
                }
            },
        )

        if not result:
            raise HTTPException(
                status_code=409,
                detail="Order state changed (may have been accepted). Please refresh.",
            )

        return {
            "message": "Dispute opened successfully",
            "order_id": order_id,
        }

    async def resolve_dispute(self, order_id: str, decision: str, resolution_note: str = ""):
       
        if decision not in ("freelancer_wins", "customer_wins"):
            raise HTTPException(status_code=400, detail="Invalid decision")

        order_oid = validate_object_id(order_id)
        order = await self.db.orders.find_one({"_id": order_oid})

        if not order:
            raise HTTPException(status_code=404, detail="Order not found")

        if order.get("dispute_status") != "open":
            raise HTTPException(status_code=400, detail="No active dispute")

        if order.get("status") != "disputed":
            raise HTTPException(status_code=400, detail="Order is not in disputed state")

        if decision == "freelancer_wins":
            # --- Fix #7: Actually release payment via Stripe ---
            # Temporarily set status to non-disputed so release_payment doesn't block
            await self.db.orders.update_one(
                {"_id": order_oid},
                {"$set": {"status": "completed"}},
            )

            try:
                await self.payment_service.release_payment(order_id)
            except HTTPException as e:
                # Rollback status if release failed
                await self.db.orders.update_one(
                    {"_id": order_oid},
                    {"$set": {"status": "disputed"}},
                )
                raise HTTPException(
                    status_code=500,
                    detail=f"Failed to release payment: {e.detail}",
                )

            
            await self.db.orders.update_one(
                {"_id": order_oid},
                {
                    "$set": {
                        "status": "completed",
                        "dispute_status": "resolved",
                        "dispute_resolution": resolution_note or "Resolved in favor of freelancer",
                        "completed_at": datetime.now(timezone.utc),
                        "updated_at": datetime.now(timezone.utc),
                    }
                },
            )

            return {
                "message": "Freelancer wins dispute. Payment released.",
                "order_id": order_id,
            }

        elif decision == "customer_wins":
            # Refund the customer
            payment_intent_id = order.get("stripe_payment_intent_id")

            if payment_intent_id:
                # Check if already refunded on Stripe side
                try:
                    refunds = stripe.Refund.list(payment_intent=payment_intent_id)
                    if refunds.data:
                        raise HTTPException(status_code=400, detail="Already refunded on Stripe")

                    stripe.Refund.create(payment_intent=payment_intent_id)
                except stripe.error.StripeError as e:
                    raise HTTPException(
                        status_code=500,
                        detail=f"Stripe refund failed: {str(e)}",
                    )

            await self.db.orders.update_one(
                {"_id": order_oid},
                {
                    "$set": {
                        "status": "cancelled",
                        "payment_status": "refunded",
                        "dispute_status": "resolved",
                        "dispute_resolution": resolution_note or "Resolved in favor of customer",
                        "updated_at": datetime.now(timezone.utc),
                    }
                },
            )

            return {
                "message": "Customer wins dispute. Payment refunded.",
                "order_id": order_id,
            }

    async def get_disputes(self, status_filter: str = "all"):
        """
        Admin lists disputes.
        status_filter: 'open', 'resolved', or 'all'
        """
        query = {"dispute_status": {"$ne": "none"}}

        if status_filter == "open":
            query["dispute_status"] = "open"
        elif status_filter == "resolved":
            query["dispute_status"] = "resolved"

        orders = await self.db.orders.find(query).sort(
            "updated_at", -1
        ).to_list(length=100)

        return [
            {**order, "_id": str(order["_id"])}
            for order in orders
        ]