from core.database import db
from bson import ObjectId
from fastapi import HTTPException, status
from utils.Pyobject import validate_object_id

class AdminService:
    def __init__(self):
        self.db = db

    def _serialize_user(self, user: dict) -> dict:
        serialized = dict(user)
        serialized["_id"] = str(serialized["_id"])
        serialized.pop("password", None)  # Safety: never send passwords
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


        