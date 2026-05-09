from core.database import db
from datetime import datetime
class AnalyticService:
    def __init__(self):
        self.db = db
        
        
    async def total_earnings(self, user_id: str):
        pipeline=[
            {"$match":{"freelancer_id":user_id,"status":"completed"}},
            {"$group":{"_id":"$freelancer_id","total":{"$sum":"$amount"}}}
        ]
        result = await self.db.orders.aggregate(pipeline).to_list(length=1)
        return result[0]["total"] if result else 0

    async def total_orders(self, user_id: str):
        pipeline=[
            {"$match":{"freelancer_id":user_id}},
            {"$group":{"_id":"$freelancer_id","count":{"$sum":1}}}   
        ]
        result = await self.db.orders.aggregate(pipeline).to_list(length=1)
        return result[0]["count"] if result else 0
    
    async def current_month_earnings(self, user_id: str):
        
        now = datetime.utcnow()
        start_of_month = datetime(now.year, now.month, 1)
        
        pipeline=[
            {"$match":{
                "freelancer_id":user_id,
                "status":"completed",
                "completed_at":{"$gte":start_of_month}
            }},
            {"$group":{"_id":"$freelancer_id","total":{"$sum":"$amount"}}}
        ]
        result = await self.db.orders.aggregate(pipeline).to_list(length=1)
        return result[0]["total"] if result else 0
    
    
    async def pending_order(self,user_id:str):
        pipeline=[
            {"$match":{"freelancer_id":user_id,"status":"pending"}},
            {"$group":{"_id":"$freelancer_id","count":{"$sum":1}}}
        ]
        result= await self.db.orders.aggregate(pipeline).to_list(length=1)
        return result[0]["count"] if result else 0
    
    
    async def recent_orders(self,user_id:str):
        pipeline=[
            {"$match":{"freelancer_id":user_id}},
            {"$sort":{"created_at":-1}},
            {"$limit":5}
        ]
        result = await self.db.orders.aggregate(pipeline).to_list(length=5)
        return result
    