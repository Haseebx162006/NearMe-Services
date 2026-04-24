from core.database import db
from bson import ObjectId
from fastapi import HTTPException, status
import heapq
from typing import List


class GigService:
    def __init__(self):
        self.db = db

    def get_ranked_gigs(self, gigs: List[dict], sort_by: str, limit: int) -> List[dict]:
        """
        Ranks and sorts gigs in-memory using a Heap (Priority Queue).
        - rating: Max Heap (using negative values)
        - price: Min Heap
        - distance: Min Heap
        """
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

    def _to_object_id(self, value: str, field_name: str) -> ObjectId:
        if not ObjectId.is_valid(value):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Invalid {field_name}")
        return ObjectId(value)

    def _serialize_gig(self, gig: dict) -> dict:
        serialized = dict(gig)
        serialized["_id"] = str(serialized["_id"])
        return serialized
    
    async def create_gig(self, data: dict, freelancer_id: str):
        user = await self.db.users.find_one({"_id": self._to_object_id(freelancer_id, "freelancer_id")})
        
        if user is None:
            raise HTTPException(status_code=404, detail="User not found")
        
        payload = dict(data)
        payload['freelancer_id'] = freelancer_id
        
        result = await self.db.gigs.insert_one(payload)
        return str(result.inserted_id)
    
    
    async def delete_gig(self, gig_id: str, freelancer_id: str):
        gig_object_id = self._to_object_id(gig_id, "gig_id")
        gig = await self.db.gigs.find_one({"_id": gig_object_id, "freelancer_id": freelancer_id})
        
        if gig is None:
            raise HTTPException(status_code=404, detail="Gig not found or you don't have permission to delete this gig")
        
        await self.db.gigs.delete_one({"_id": gig_object_id})
        return {"message": "Gig deleted successfully"}
    
    
    async def get_gig_by_id(self, gig_id: str):
        gig = await self.db.gigs.find_one({"_id": self._to_object_id(gig_id, "gig_id")})
        if not gig:
            raise HTTPException(status_code=404, detail="Gig not found")
        return self._serialize_gig(gig)
    
    async def get_gigs_by_freelancer(self, freelancer_id: str):
        gigs= await self.db.gigs.find({"freelancer_id": freelancer_id}).to_list(length=100)
        if not gigs:
            raise HTTPException(status_code=404, detail="No gigs found for this freelancer")
        return [self._serialize_gig(gig) for gig in gigs]
    
    async def get_all_gigs(self):
        gigs = await self.db.gigs.find().to_list(length=100)
        if not gigs:
            raise HTTPException(status_code=404, detail="No gigs found")
        return [self._serialize_gig(gig) for gig in gigs]
    
    
    async def update_gig(self, gig_id: str, data: dict, freelancer_id: str):
        gig_object_id = self._to_object_id(gig_id, "gig_id")
        gig = await self.db.gigs.find_one({"_id": gig_object_id, "freelancer_id": freelancer_id})
        
        if gig is None:
            raise HTTPException(status_code=404, detail="Gig not found or you don't have permission to update this gig")
        
        update_data = dict(data)
        update_data.pop("_id", None)
        update_data.pop("freelancer_id", None)

        await self.db.gigs.update_one({"_id": gig_object_id}, {"$set": update_data})
        return {"message": "Gig updated successfully"}