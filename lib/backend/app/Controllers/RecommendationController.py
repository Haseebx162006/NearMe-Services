from Service.RecommendationService import RecommendationService
from fastapi import HTTPException

class RecommendationController:
    def __init__(self):
        self.service = RecommendationService()
        
    async def get_user_recommendations(self, user_id: str):
        try:
            recommendations = await self.service.get_recommendations(user_id)
            return {
                "user": f"user_{user_id}",
                "recommendations": recommendations
            }
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
