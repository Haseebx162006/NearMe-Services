from fastapi import HTTPException, UploadFile
from core.database import db
from utils.Pyobject import validate_object_id
from Service.CloudinaryService import CloudinaryService
from Service.PaymentService import PaymentService
from datetime import datetime, timezone


class DeliveryService:
    """
    Handles the delivery lifecycle for orders:
    - Freelancer submits work (files + message)
    - Customer accepts delivery (triggers payment release)
    - Customer rejects delivery (sends back for revision)
    """

    def __init__(self):
        self.db = db
        self.cloudinary_service = CloudinaryService()
        self.payment_service = PaymentService()

    async def submit_delivery(
        self,
        order_id: str,
        freelancer_id: str,
        files: list[UploadFile],
        message: str = "",
    ):
        """
        Freelancer submits delivery files for an order.
        Uploads files to Cloudinary and updates the order status.

        Fix #13: Pushes into the `deliveries` array (matches Order model).
        Fix #16: Uses find_one_and_update for atomic status transition.
        """
        order_oid = validate_object_id(order_id)
        order = await self.db.orders.find_one({"_id": order_oid})

        if not order:
            raise HTTPException(status_code=404, detail="Order not found")

        # --- Ownership check ---
        if str(order.get("freelancer_id")) != freelancer_id:
            raise HTTPException(
                status_code=403,
                detail="You can only submit deliveries for your own orders",
            )

        # --- Status guard: only in_progress orders can be delivered ---
        current_status = order.get("status")
        if current_status != "in_progress":
            raise HTTPException(
                status_code=400,
                detail=f"Cannot submit delivery for order with status '{current_status}'. "
                       f"Order must be in_progress.",
            )

        # --- Upload files to Cloudinary ---
        uploaded_urls = []
        for file in files:
            file_bytes = await file.read()
            result = await self.cloudinary_service.upload_file(
                file_bytes=file_bytes,
                filename=file.filename or "delivery_file",
                folder=f"nearme/deliveries/{order_id}",
            )
            uploaded_urls.append(result["url"])

        # --- Fix #13: Push into deliveries array (matches Order model schema) ---
        delivery_version = len(order.get("deliveries", [])) + 1
        delivery_doc = {
            "files": uploaded_urls,
            "message": message,
            "created_at": datetime.now(timezone.utc),
            "version": delivery_version,
        }

        # --- Fix #16: Atomic status transition ---
        result = await self.db.orders.find_one_and_update(
            {"_id": order_oid, "status": "in_progress"},
            {
                "$push": {"deliveries": delivery_doc},
                "$set": {
                    "status": "delivered",
                    "updated_at": datetime.now(timezone.utc),
                },
            },
        )

        if not result:
            raise HTTPException(
                status_code=409,
                detail="Order state changed during delivery submission. Please retry.",
            )

        return {
            "message": "Delivery submitted successfully",
            "delivery_files": uploaded_urls,
            "version": delivery_version,
        }

    async def accept_delivery(self, order_id: str, customer_id: str):
        """
        Customer accepts the delivery.
        Triggers payment release to the freelancer.

        Fix #8:  Atomic status check prevents race with create_dispute.
        Fix #20: No silent except — rolls back on payment failure.
        """
        order_oid = validate_object_id(order_id)
        order = await self.db.orders.find_one({"_id": order_oid})

        if not order:
            raise HTTPException(status_code=404, detail="Order not found")

        # --- Ownership check ---
        if str(order.get("customer_id")) != customer_id:
            raise HTTPException(
                status_code=403,
                detail="You can only accept deliveries for your own orders",
            )

        # --- Fix #8: Atomic status transition (prevents race with dispute) ---
        result = await self.db.orders.find_one_and_update(
            {
                "_id": order_oid,
                "status": "delivered",
            },
            {
                "$set": {
                    "status": "completed",
                    "completed_at": datetime.now(timezone.utc),
                    "updated_at": datetime.now(timezone.utc),
                }
            },
        )

        if not result:
            raise HTTPException(
                status_code=409,
                detail="Order state changed (may have been disputed). Please refresh.",
            )

        # --- Fix #20: No silent pass — rollback on failure ---
        try:
            await self.payment_service.release_payment(order_id)
        except HTTPException as e:
            # Rollback the delivery acceptance
            await self.db.orders.update_one(
                {"_id": order_oid},
                {
                    "$set": {
                        "status": "delivered",
                        "completed_at": None,
                    }
                },
            )
            raise HTTPException(
                status_code=500,
                detail=f"Delivery accepted but payment release failed: {e.detail}. "
                       f"Order has been rolled back. Please contact support.",
            )

        return {"message": "Delivery accepted and payment released"}

    async def reject_delivery(self, order_id: str, customer_id: str, reason: str = ""):
        """
        Customer rejects the delivery.
        Order goes back to in_progress so the freelancer can revise.

        Fix #16: Atomic status transition.
        """
        order_oid = validate_object_id(order_id)
        order = await self.db.orders.find_one({"_id": order_oid})

        if not order:
            raise HTTPException(status_code=404, detail="Order not found")

        # --- Ownership check ---
        if str(order.get("customer_id")) != customer_id:
            raise HTTPException(
                status_code=403,
                detail="You can only reject deliveries for your own orders",
            )

        # --- Fix #16: Atomic status transition ---
        result = await self.db.orders.find_one_and_update(
            {
                "_id": order_oid,
                "status": "delivered",
            },
            {
                "$set": {
                    "status": "in_progress",
                    "updated_at": datetime.now(timezone.utc),
                }
            },
        )

        if not result:
            raise HTTPException(
                status_code=409,
                detail="Order state changed. Please refresh.",
            )

        return {"message": "Delivery rejected. Freelancer can revise and resubmit."}
