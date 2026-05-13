from fastapi import APIRouter, Depends
from Controllers.RecommendationController import RecommendationController

# We create the router with its custom prefix and tags
router = APIRouter(
    prefix="/recommend",
    tags=["Recommendations"]
)

controller = RecommendationController()

@router.get("/{user_id}")
async def get_recommendations(user_id: str):
    """
    Returns gig recommendations based on a Bipartite Graph BFS algorithm.
    It checks what other overlapping users bought and suggests those.
    """
    return await controller.get_user_recommendations(user_id)
