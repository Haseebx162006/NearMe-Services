from schema.OrderSchema import CreateOrderSchema
from fastapi import HTTPException, status
from core.database import db
from bson import ObjectId
from utils.Pyobject import validate_object_id
from datetime import datetime, timezone


# --- Fix #9: Status transition whitelist ---
ALLOWED_TRANSITIONS = {
    "pending":     ["accepted", "cancelled"],
    "accepted":    ["in_progress", "cancelled", "completed"],
    "in_progress": ["delivered", "completed"],
    "delivered":   ["completed"],
    # "disputed", "completed", "cancelled" are managed exclusively by dedicated services
    # where needed, but completed is now allowed with automated payment release integration.
}


class OrderService:
    def __init__(self):
        self.db = db

    async def _serialize_order(self, order: dict):
        serialized = dict(order)
        serialized["_id"] = str(serialized["_id"])
        serialized.setdefault("reviewed", False)

        if "customer_id" in serialized:
            try:
                cust_oid = validate_object_id(serialized["customer_id"])
                customer = await self.db.users.find_one({"_id": cust_oid})
                serialized["customer_name"] = (
                    customer["name"] if customer else "Unknown Customer"
                )
            except ValueError:
                serialized["customer_name"] = "Unknown Customer"

        if "freelancer_id" in serialized:
            try:
                free_oid = validate_object_id(serialized["freelancer_id"])
                freelancer = await self.db.users.find_one({"_id": free_oid})
                serialized["freelancer_name"] = (
                    freelancer["name"] if freelancer else "Unknown Provider"
                )
            except ValueError:
                serialized["freelancer_name"] = "Unknown Provider"

        if "gig_id" in serialized:
            try:
                gig_oid = validate_object_id(serialized["gig_id"])
                gig = await self.db.gigs.find_one({"_id": gig_oid})
                serialized["gig_title"] = gig["title"] if gig else "Unknown Gig"
            except ValueError:
                serialized["gig_title"] = "Unknown Gig"

        return serialized

    async def _serialize_orders_bulk(self, orders: list):
        if not orders:
            return []

        # Collect all IDs safely
        customer_ids = set()
        freelancer_ids = set()
        gig_ids = set()
        for o in orders:
            if "customer_id" in o:
                try:
                    customer_ids.add(validate_object_id(o["customer_id"]))
                except ValueError:
                    pass
            if "freelancer_id" in o:
                try:
                    freelancer_ids.add(validate_object_id(o["freelancer_id"]))
                except ValueError:
                    pass
            if "gig_id" in o:
                try:
                    gig_ids.add(validate_object_id(o["gig_id"]))
                except ValueError:
                    pass

        # Query in bulk
        customers_task = self.db.users.find({"_id": {"$in": list(customer_ids)}}).to_list(length=len(customer_ids) + 1) if customer_ids else []
        freelancers_task = self.db.users.find({"_id": {"$in": list(freelancer_ids)}}).to_list(length=len(freelancer_ids) + 1) if freelancer_ids else []
        gigs_task = self.db.gigs.find({"_id": {"$in": list(gig_ids)}}).to_list(length=len(gig_ids) + 1) if gig_ids else []

        # Await all parallel queries
        import asyncio
        results = await asyncio.gather(
            asyncio.ensure_future(customers_task) if customer_ids else asyncio.sleep(0, []),
            asyncio.ensure_future(freelancers_task) if freelancer_ids else asyncio.sleep(0, []),
            asyncio.ensure_future(gigs_task) if gig_ids else asyncio.sleep(0, [])
        )
        
        customers = results[0] if customer_ids else []
        freelancers = results[1] if freelancer_ids else []
        gigs = results[2] if gig_ids else []

        # Create lookup maps
        customer_map = {str(c["_id"]): c.get("name", "Unknown Customer") for c in customers}
        freelancer_map = {str(f["_id"]): f.get("name", "Unknown Provider") for f in freelancers}
        gig_map = {str(g["_id"]): g.get("title", "Unknown Gig") for g in gigs}

        serialized_orders = []
        for o in orders:
            serialized = dict(o)
            serialized["_id"] = str(serialized["_id"])
            serialized.setdefault("reviewed", False)

            cust_id = str(serialized.get("customer_id", ""))
            serialized["customer_name"] = customer_map.get(cust_id, "Unknown Customer")

            free_id = str(serialized.get("freelancer_id", ""))
            serialized["freelancer_name"] = freelancer_map.get(free_id, "Unknown Provider")

            g_id = str(serialized.get("gig_id", ""))
            serialized["gig_title"] = gig_map.get(g_id, "Unknown Gig")

            serialized_orders.append(serialized)

        return serialized_orders

    async def customer_has_pending_review(self, customer_id: str) -> bool:
        query_ids = [customer_id]
        try:
            query_ids.append(validate_object_id(customer_id))
        except ValueError:
            pass

        pending = await self.db.orders.find_one(
            {
                "customer_id": {"$in": query_ids},
                "status": "completed",
                "$or": [{"reviewed": {"$exists": False}}, {"reviewed": False}],
            }
        )
        return pending is not None

    async def submit_review(
        self, order_id: str, customer_id: str, rating: int, comment=None
    ):
        if rating < 1 or rating > 5:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Rating must be between 1 and 5",
            )

        order_object_id = validate_object_id(order_id)
        order = await self.db.orders.find_one({"_id": order_object_id})

        if order is None:
            raise HTTPException(status_code=404, detail="Order not found")

        if str(order.get("customer_id")) != customer_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only review your own orders",
            )

        if order.get("status") != "completed":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Only completed orders can be reviewed",
            )

        if order.get("reviewed"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This order has already been reviewed",
            )

        await self.db.orders.update_one(
            {"_id": order_object_id},
            {
                "$set": {
                    "reviewed": True,
                    "rating": rating,
                    "review_comment": comment,
                }
            },
        )

        gig_id = order.get("gig_id")
        if gig_id:
            reviews = await self.db.orders.find(
                {"gig_id": gig_id, "reviewed": True, "rating": {"$exists": True}}
            ).to_list(length=500)
            if reviews:
                avg = sum(r.get("rating", 0) for r in reviews) / len(reviews)
                await self.db.gigs.update_one(
                    {"_id": validate_object_id(gig_id)},
                    {"$set": {"rating": round(avg, 2)}},
                )

        return {"message": "Review submitted successfully"}
    
    async def create_order(self, order_data: dict):
        if not order_data:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid order data")

        customer_id = str(order_data.get("customer_id", ""))
        if customer_id and await self.customer_has_pending_review(customer_id):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Please review your completed order before placing a new one",
            )

        if "status" not in order_data:
            order_data["status"] = "pending"

        order_data["reviewed"] = False

        # --- Fix #21: Use timezone-aware datetime ---
        order_data["created_at"] = datetime.now(timezone.utc)
        
        Order = await self.db.orders.insert_one(order_data)
        return str(Order.inserted_id)
     
     
    async def get_order_by_id(self, order_id: str):
        # Logic to retrieve an order by its ID from the database
        
        order = await self.db.orders.find_one({"_id": validate_object_id(order_id)})
        if not order:
            raise HTTPException(status_code=404, detail="Order not found")
        return await self._serialize_order(order)
    
    
    async def get_orders_by_user(self, user_id: str):
        # Logic to retrieve all orders for a specific user from the database
        query_ids = [user_id]
        try:
            query_ids.append(validate_object_id(user_id))
        except ValueError:
            pass

        orders = await self.db.orders.find({
            "$or": [
                {"customer_id": {"$in": query_ids}},
                {"freelancer_id": {"$in": query_ids}},
            ]
        }).to_list(length=100)
        
        return await self._serialize_orders_bulk(orders)

    async def get_orders_as_freelancer(self, freelancer_id: str):
        query_ids = [freelancer_id]
        try:
            query_ids.append(validate_object_id(freelancer_id))
        except ValueError:
            pass

        orders = await self.db.orders.find({"freelancer_id": {"$in": query_ids}}).to_list(length=100)
        return await self._serialize_orders_bulk(orders)

    async def get_orders_as_customer(self, customer_id: str):
        query_ids = [customer_id]
        try:
            query_ids.append(validate_object_id(customer_id))
        except ValueError:
            pass

        orders = (
            await self.db.orders.find({"customer_id": {"$in": query_ids}})
            .sort("created_at", -1)
            .to_list(length=100)
        )
        return await self._serialize_orders_bulk(orders)
    
    async def delete_order(self, order_id: str):
        """
        Fix #19: Add guards to prevent deleting orders with active payments or disputes.
        """
        order_object_id = validate_object_id(order_id)
        order = await self.db.orders.find_one({"_id": order_object_id})
        
        if order is None:
            raise HTTPException(status_code=404, detail="Order not found")

        # --- Fix #19: Safety guards ---
        if order.get("payment_status") in ("held", "released"):
            raise HTTPException(
                status_code=400,
                detail="Cannot delete order with active payment",
            )

        if order.get("dispute_status") == "open":
            raise HTTPException(
                status_code=400,
                detail="Cannot delete order with an open dispute",
            )

        if order.get("status") in ("in_progress", "delivered", "disputed"):
            raise HTTPException(
                status_code=400,
                detail=f"Cannot delete order with status '{order.get('status')}'",
            )
        
        await self.db.orders.delete_one({"_id": order_object_id})
        return {"message": "Order deleted successfully"}
    
    async def update_order(self, order_id: str, order_data: dict):
        """
        Fix #9: Enforces a status transition whitelist.
        Only allowed transitions can be made via this generic endpoint.
        Critical transitions (delivered, disputed, completed) are managed
        by their respective dedicated services.
        """
        order_object_id = validate_object_id(order_id)
        order = await self.db.orders.find_one({"_id": order_object_id})
        
        if order is None:
            raise HTTPException(status_code=404, detail="Order not found")
        
        update_data = dict(order_data)
        if not update_data:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid order data")

        # --- Fix #9: Status transition validation ---
        new_status = update_data.get("status")
        if new_status:
            current_status = order.get("status")
            allowed = ALLOWED_TRANSITIONS.get(current_status, [])

            if new_status not in allowed:
                raise HTTPException(
                    status_code=400,
                    detail=f"Cannot transition from '{current_status}' to '{new_status}'. "
                           f"Allowed: {allowed}",
                )
        
        # --- Fix #21: timezone-aware datetime ---
        if update_data.get("status") == "cancelled" and order.get("payment_status") == "held":
            from Service.PaymentService import PaymentService
            payment_service = PaymentService()
            try:
                await payment_service.refund_payment(order_id)
                return {"message": "Order cancelled and payment refunded successfully"}
            except HTTPException as e:
                raise e
            except Exception as e:
                raise HTTPException(
                    status_code=500,
                    detail=f"Status update failed because payment refund failed: {str(e)}",
                )

        if update_data.get("status") == "completed":
            # If transitioning to completed, release the payment first via Stripe
            from Service.PaymentService import PaymentService
            payment_service = PaymentService()
            try:
                await payment_service.release_payment(order_id)
            except HTTPException as e:
                # If payment release fails, propagate the HTTPException to abort the state transition
                raise e
            except Exception as e:
                raise HTTPException(
                    status_code=500,
                    detail=f"Status update failed because payment release failed: {str(e)}",
                )
            update_data["completed_at"] = datetime.now(timezone.utc)

        update_data["updated_at"] = datetime.now(timezone.utc)
        
        update_data.pop("_id", None)
        await self.db.orders.update_one({"_id": order_object_id}, {"$set": update_data})
        return {"message": "Order updated successfully"}

    async def enqueue_acceptance_request(self, order_id: str, freelancer_id: str):
       
       
        validate_object_id(order_id)
        
        from task_queue.AcceptanceQueue import order_queue
        
        # Enqueue the request
        order_queue.enqueue({
            "order_id": order_id,
            "freelancer_id": freelancer_id
        })
        
        return {"message": "Order acceptance request added to queue successfully"}

    async def assign_order_atomically(self, order_id: str, freelancer_id: str):
       
        order_object_id = validate_object_id(order_id)
        
        updated_order = await self.db.orders.find_one_and_update(
            {"_id": order_object_id, "status": "OPEN"},
            {"$set": {
                "status": "ASSIGNED", 
                "assigned_freelancer_id": freelancer_id
            }},
            return_document=True  # Returns the updated document if successful
        )
        
        if updated_order:
            return True
        else:
            return False