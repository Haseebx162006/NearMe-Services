from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from Service.AnalyticsService import AnalyticService

router = APIRouter(prefix='/analytics')
analytics_service = AnalyticService()

@router.get('/earnings/{user_id}')
async def get_total_earnings(user_id: str):
    try:
        earnings = await analytics_service.total_earnings(user_id)
        return {"success": True, "data": {"totalEarnings": earnings}}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get('/monthly-earnings/{user_id}')
async def get_monthly_earnings(user_id: str):
    try:
        earnings = await analytics_service.current_month_earnings(user_id)
        return {"success": True, "data": {"monthEarnings": earnings}}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get('/total-orders/{user_id}')
async def get_total_orders(user_id: str):
    try:
        orders = await analytics_service.total_orders(user_id)
        return {"success": True, "data": {"totalOrders": orders}}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
