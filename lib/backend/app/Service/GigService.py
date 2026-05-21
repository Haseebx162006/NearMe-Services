from core.database import db
from bson import ObjectId
from fastapi import HTTPException, status
import heapq
from typing import List
from utils.Pyobject import validate_object_id
from datetime import datetime, timezone


class GigService:
    def __init__(self):
        self.db = db

    def get_ranked_gigs(self, gigs: List[dict], sort_by: str, limit: int) -> List[dict]:
        
        heap = []
        
        for gig in gigs:
            
            if sort_by == "rating":
                
                key = -gig.get("rating", 0.0)
            elif sort_by == "price":
                
                key = gig.get("price", float('inf'))
            elif sort_by == "distance":
               
                key = gig.get("distance", float('inf'))
            else:
                
                key = -gig.get("rating", 0.0)
            
            
            heapq.heappush(heap, (key, id(gig), gig))

        ranked_gigs = []
        # Extract top-K using heappop
        for _ in range(min(limit, len(heap))):
            _, _, gig = heapq.heappop(heap)
            ranked_gigs.append(gig)
            
        return ranked_gigs

    async def _serialize_gig(self, gig: dict) -> dict:
        serialized = dict(gig)
        serialized["_id"] = str(serialized["_id"])
        if "freelancer_id" in serialized:
            fid = str(serialized["freelancer_id"])
            serialized["freelancer_id"] = fid
            try:
                user = await self.db.users.find_one(
                    {"_id": validate_object_id(fid)}
                )
                if user:
                    serialized["freelancer_name"] = user.get("name", "Freelancer")
                    serialized["freelancer_rating"] = float(
                        user.get("rating") or 0.0
                    )
                    serialized["freelancer_email"] = user.get("email", "")
                    serialized["freelancer_phone"] = user.get("phone_number", "")
                    serialized["freelancer_bio"] = user.get("profile_bio", "") or ""
                    serialized["freelancer_skills"] = user.get("skills", []) or []
            except Exception:
                pass
        return serialized
    
    async def create_gig(self, data: dict, freelancer_id: str):
        user = await self.db.users.find_one({"_id": validate_object_id(freelancer_id)})
        
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")
        
        payload = dict(data)
        payload['freelancer_id'] = freelancer_id
        # Backward compatible fields for frontend models
        payload.setdefault("created_at", datetime.now(timezone.utc))
        payload.setdefault("is_active", True)
        # New moderation field for admin panel (old gigs won't have it)
        payload.setdefault("moderation_status", "pending")
        
        result = await self.db.gigs.insert_one(payload)
        return str(result.inserted_id)
    
    
    async def delete_gig(self, gig_id: str, freelancer_id: str):
        gig_object_id = validate_object_id(gig_id)
        gig = await self.db.gigs.find_one({"_id": gig_object_id, "freelancer_id": freelancer_id})
        
        if gig is None:
            raise HTTPException(status_code=404, detail="Gig not found or you don't have permission to delete this gig")
        
        await self.db.gigs.delete_one({"_id": gig_object_id})
        return {"message": "Gig deleted successfully"}

    async def get_gig_by_id(self, gig_id: str):
        gig = await self.db.gigs.find_one({"_id": validate_object_id(gig_id)})
        if not gig:
            raise HTTPException(status_code=404, detail="Gig not found")
        serialized = await self._serialize_gig(gig)
        fid = serialized.get("freelancer_id")
        if fid:
            try:
                from Service.UserService import UserService

                profile = await UserService().get_public_profile(fid)
                serialized["freelancer_name"] = profile.get("name")
                serialized["freelancer_rating"] = profile.get("rating")
                serialized["freelancer_review_count"] = profile.get("review_count")
            except Exception:
                pass
        return serialized

    async def get_gigs_by_freelancer(self, freelancer_id: str):
        gigs = await self.db.gigs.find({"freelancer_id": freelancer_id}).to_list(
            length=100
        )
        if not gigs:
            raise HTTPException(
                status_code=404, detail="No gigs found for this freelancer"
            )
        return [await self._serialize_gig(gig) for gig in gigs]

    async def get_all_gigs(self, freelancer_id: str = None):
        query = {}
        if freelancer_id:
            query["freelancer_id"] = freelancer_id
            
        gigs = await self.db.gigs.find(query).to_list(length=100)
        if not gigs:
            raise HTTPException(status_code=404, detail="No gigs found")
        return [await self._serialize_gig(gig) for gig in gigs]
    
    
    async def update_gig(self, gig_id: str, data: dict, freelancer_id: str):
        gig_object_id = validate_object_id(gig_id)
        gig = await self.db.gigs.find_one({"_id": gig_object_id, "freelancer_id": freelancer_id})
        
        if gig is None:
            raise HTTPException(status_code=404, detail="Gig not found or you don't have permission to update this gig")
        
        update_data = dict(data)
        update_data.pop("_id", None)
        update_data.pop("freelancer_id", None)

        await self.db.gigs.update_one({"_id": gig_object_id}, {"$set": update_data})
        return {"message": "Gig updated successfully"}