from core.database import db
from bson import ObjectId
from fastapi import HTTPException, status
from utils.Pyobject import validate_object_id
from datetime import datetime, timezone

class AdminService:
    def __init__(self):
        self.db = db

    def _serialize_user(self, user: dict) -> dict:
        serialized = dict(user)
        serialized["_id"] = str(serialized["_id"])
        serialized.pop("password", None)  
        serialized.pop("passwrd", None)   
        return serialized
    
    async def get_all_users(self):
        users = await self.db.users.find().to_list(length=1000)
        return [self._serialize_user(user) for user in users]

    async def suspend_account(self, user_id: str, remark: str = "Suspended by admin"):
        user_object_id = validate_object_id(user_id)
        user = await self.db.users.find_one({"_id": user_object_id})
        
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")
        
        await self.db.users.update_one(
            {"_id": user_object_id}, 
            {"$set": {"is_active": False, "suspension_remark": remark}}
        )
        return {"message": "Account suspended successfully"}

    async def reactivate_account(self, user_id: str):
        user_object_id = validate_object_id(user_id)
        user = await self.db.users.find_one({"_id": user_object_id})
        
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")
        
        await self.db.users.update_one(
            {"_id": user_object_id}, 
            {"$set": {"is_active": True, "suspension_remark": None}}
        )
        return {"message": "Account reactivated successfully"}


    def _serialize_doc(self, doc: dict) -> dict:
        """
        Converts MongoDB types into JSON-safe types (ObjectId -> str).
        Keeps the function small and easy to understand for beginners.
        """
        if doc is None:
            return {}

        serialized = dict(doc)
        if "_id" in serialized:
            serialized["_id"] = str(serialized["_id"])

        for key, value in list(serialized.items()):
            if isinstance(value, ObjectId):
                serialized[key] = str(value)
            elif isinstance(value, datetime):
                serialized[key] = value.isoformat()
        return serialized



    async def get_dashboard_stats(self) -> dict:
        
        total_users = await self.db.users.count_documents({})
        total_gigs = await self.db.gigs.count_documents({})
        total_orders = await self.db.orders.count_documents({})

        # Revenue: sum of payments amounts that succeeded/held/released.
        pipeline = [
            {"$match": {"status": {"$in": ["held", "released", "succeeded"]}}},
            {"$group": {"_id": None, "total": {"$sum": "$amount"}}},
        ]
        result = await self.db.payments.aggregate(pipeline).to_list(length=1)
        total_revenue = float(result[0]["total"]) if result else 0.0

        # Recent activity (simple + generic)
        recent_users = await self.db.users.find().sort("created_at", -1).limit(3).to_list(length=3)
        recent_gigs = await self.db.gigs.find().sort("created_at", -1).limit(3).to_list(length=3)

        activity = []
        for u in recent_users:
            activity.append({
                "title": "New user registered",
                "detail": u.get("email") or u.get("name") or "",
                "time": (u.get("created_at") or datetime.now(timezone.utc)).isoformat() if isinstance(u.get("created_at"), datetime) else str(u.get("created_at") or ""),
            })
        for g in recent_gigs:
            activity.append({
                "title": "New gig created",
                "detail": g.get("title") or "",
                "time": (g.get("created_at") or datetime.now(timezone.utc)).isoformat() if isinstance(g.get("created_at"), datetime) else str(g.get("created_at") or ""),
            })

        return {
            "total_users": total_users,
            "total_gigs": total_gigs,
            "total_orders": total_orders,
            "total_revenue": total_revenue,
            "recent_activity": activity[:6],
        }


    async def list_gigs_for_moderation(self, status_filter: str = "pending", limit: int = 50):
       
        query = {}
        if status_filter == "pending":
            query = {"moderation_status": "pending"}

        gigs = await self.db.gigs.find(query).sort("created_at", -1).to_list(length=limit)
        serialized = []
        for g in gigs:
            doc = self._serialize_doc(g)
            if "moderation_status" not in doc or not doc["moderation_status"]:
                doc["moderation_status"] = "approved"
            serialized.append(doc)
        return serialized



    async def moderate_gig(self, gig_id: str, new_status: str):
       
        if new_status not in ["approved", "rejected"]:
            raise HTTPException(status_code=400, detail="Invalid moderation status")

        gig_object_id = validate_object_id(gig_id)
        gig = await self.db.gigs.find_one({"_id": gig_object_id})
        if gig is None:
            raise HTTPException(status_code=404, detail="Gig not found")

        await self.db.gigs.update_one(
            {"_id": gig_object_id},
            {"$set": {"moderation_status": new_status}}
        )
        return {"message": f"Gig {new_status} successfully"}



    async def list_orders(self, limit: int = 50):
        
        orders = await self.db.orders.find().sort("created_at", -1).to_list(length=limit)
        return [self._serialize_doc(o) for o in orders]




    async def payments_summary(self) -> dict:
        """
        Fix #11: Query the orders collection (where payment data actually lives)
        instead of the empty payments collection.
        """
        pipeline_held = [
            {"$match": {"payment_status": "held"}},
            {"$group": {"_id": None, "total": {"$sum": "$amount"}}},
        ]
        held_result = await self.db.orders.aggregate(pipeline_held).to_list(length=1)
        total_in_escrow = float(held_result[0]["total"]) if held_result else 0.0

        pipeline_released = [
            {"$match": {"payment_status": "released"}},
            {"$group": {"_id": None, "total": {"$sum": "$amount"}}},
        ]
        released_result = await self.db.orders.aggregate(pipeline_released).to_list(length=1)
        total_released = float(released_result[0]["total"]) if released_result else 0.0

        disputed_orders = await self.db.orders.count_documents({"dispute_status": "open"})

        return {
            "total_in_escrow": total_in_escrow,
            "total_released": total_released,
            "disputed_orders": disputed_orders,
        }


        