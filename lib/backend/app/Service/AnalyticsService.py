from core.database import db
from datetime import datetime
from bson import ObjectId
from utils.Pyobject import validate_object_id

class AnalyticService:
    def __init__(self):
        self.db = db
        
    async def total_earnings(self, user_id: str):
        """Query with BOTH string and ObjectId to handle mixed storage formats."""
        obj_id = validate_object_id(user_id)
        pipeline=[
            {"$match":{
                "$or": [
                    {"freelancer_id": obj_id},
                    {"freelancer_id": str(obj_id)}
                ],
                "status": "completed"
            }},
            {"$group":{"_id": None, "total":{"$sum":"$amount"}}}
        ]
        result = await self.db.orders.aggregate(pipeline).to_list(length=1)
        return result[0]["total"] if result else 0

    async def total_orders(self, user_id: str):
        obj_id = validate_object_id(user_id)
        pipeline=[
            {"$match":{
                "$or": [
                    {"freelancer_id": obj_id},
                    {"freelancer_id": str(obj_id)}
                ]
            }},
            {"$group":{"_id": None, "count":{"$sum":1}}}   
        ]
        result = await self.db.orders.aggregate(pipeline).to_list(length=1)
        return result[0]["count"] if result else 0
    
    async def current_month_earnings(self, user_id: str):
        obj_id = validate_object_id(user_id)
        now = datetime.utcnow()
        start_of_month = datetime(now.year, now.month, 1)
        
        pipeline=[
            {"$match":{
                "$or": [
                    {"freelancer_id": obj_id},
                    {"freelancer_id": str(obj_id)}
                ],
                "status": "completed",
                "completed_at":{"$gte": start_of_month}
            }},
            {"$group":{"_id": None, "total":{"$sum":"$amount"}}}
        ]
        result = await self.db.orders.aggregate(pipeline).to_list(length=1)
        return result[0]["total"] if result else 0
    
    async def pending_order(self, user_id: str):
        obj_id = validate_object_id(user_id)
        pipeline=[
            {"$match":{
                "$or": [
                    {"freelancer_id": obj_id},
                    {"freelancer_id": str(obj_id)}
                ],
                "status": "pending"
            }},
            {"$group":{"_id": None, "count":{"$sum":1}}}
        ]
        result = await self.db.orders.aggregate(pipeline).to_list(length=1)
        return result[0]["count"] if result else 0
    
    async def recent_orders(self, user_id: str):
        obj_id = validate_object_id(user_id)
        str_id = str(obj_id)
        
        pipeline=[
            # Match orders for this freelancer (handle both string and ObjectId)
            {"$match":{
                "$or": [
                    {"freelancer_id": obj_id},
                    {"freelancer_id": str_id}
                ]
            }},
            {"$sort":{"created_at":-1}},
            {"$limit": 5},

            # Convert string customer_id to ObjectId for lookup
            {"$addFields": {
                "_customer_oid": {
                    "$cond": {
                        "if": {"$eq": [{"$type": "$customer_id"}, "string"]},
                        "then": {"$toObjectId": "$customer_id"},
                        "else": "$customer_id"
                    }
                },
                "_gig_oid": {
                    "$cond": {
                        "if": {"$eq": [{"$type": "$gig_id"}, "string"]},
                        "then": {"$toObjectId": "$gig_id"},
                        "else": "$gig_id"
                    }
                }
            }},

            # Lookup customer name
            {"$lookup": {
                "from": "users",
                "localField": "_customer_oid",
                "foreignField": "_id",
                "as": "customer"
            }},
            {"$unwind": {"path": "$customer", "preserveNullAndEmptyArrays": True}},

            # Lookup gig title
            {"$lookup": {
                "from": "gigs",
                "localField": "_gig_oid",
                "foreignField": "_id",
                "as": "gig"
            }},
            {"$unwind": {"path": "$gig", "preserveNullAndEmptyArrays": True}},

            # Project only what the frontend needs
            {"$project": {
                "_id": 1,
                "amount": 1,
                "status": 1,
                "created_at": 1,
                "customer_name": {"$ifNull": ["$customer.name", "Customer"]},
                "gig_title": {"$ifNull": ["$gig.title", "Service"]}
            }}
        ]
        result = await self.db.orders.aggregate(pipeline).to_list(length=5)
        return result