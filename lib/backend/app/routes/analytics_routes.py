from fastapi import APIRouter, Depends
from Controllers.AnalyticsController import AnalyticsController
from core.checker import role_checker

router = APIRouter(prefix='/analytics', tags=['Analytics'])
controller = AnalyticsController()

@router.get('/me')
async def get_my_analytics(current_user: dict = Depends(role_checker('freelancer'))):
    return await controller.get_freelancer_analytics(str(current_user['_id']))
