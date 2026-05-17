from datetime import datetime
from fastapi import HTTPException, status
from core.database import db
from utils.Pyobject import validate_object_id


class UserService:
    def __init__(self):
        self.db = db

    def _freelancer_id_filter(self, freelancer_id: str, obj_id):
        return {
            "$or": [
                {"freelancer_id": freelancer_id},
                {"freelancer_id": obj_id},
                {"freelancer_id": str(obj_id)},
            ]
        }

    async def get_public_profile(self, user_id: str):
        try:
            obj_id = validate_object_id(user_id.strip())
        except Exception:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid user id",
            )

        user = await self.db.users.find_one({"_id": obj_id})
        if user is None:
            user = await self.db.users.find_one({"_id": user_id.strip()})
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found",
            )

        fid = str(obj_id)
        fid_filter = self._freelancer_id_filter(fid, obj_id)

        gig_count = await self.db.gigs.count_documents(fid_filter)
        completed_orders = await self.db.orders.count_documents(
            {**fid_filter, "status": "completed"}
        )
        reviews = await self.db.orders.find(
            {**fid_filter, "reviewed": True, "rating": {"$exists": True}}
        ).to_list(length=500)

        avg_review = 0.0
        if reviews:
            avg_review = sum(r.get("rating", 0) for r in reviews) / len(reviews)

        stored_rating = user.get("rating") or 0.0
        display_rating = stored_rating if stored_rating > 0 else round(avg_review, 1)

        return {
            "_id": fid,
            "name": user.get("name", "Freelancer"),
            "email": user.get("email", ""),
            "phone_number": user.get("phone_number", ""),
            "profile_picture": user.get("profile_picture"),
            "profile_bio": user.get("profile_bio", "") or "",
            "skills": user.get("skills", []) or [],
            "role": user.get("role", ""),
            "rating": display_rating,
            "review_count": len(reviews),
            "gig_count": gig_count,
            "completed_orders": completed_orders,
            "created_at": user.get("created_at").isoformat()
            if isinstance(user.get("created_at"), datetime)
            else None,
        }
