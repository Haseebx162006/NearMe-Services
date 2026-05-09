from fastapi import APIRouter, Depends, status, Body, Query
from Controllers.AdminController import AdminController
from core.checker import role_checker

router = APIRouter(
    prefix="/admin",
    tags=["Admin"]
)

controller = AdminController()

@router.get("/users")
async def get_all_users(current_user: dict = Depends(role_checker("admin"))):
    return await controller.get_all_users()

@router.post("/users/{user_id}/suspend")
async def suspend_user(
    user_id: str, 
    remark: str = Body(..., embed=True), 
    current_user: dict = Depends(role_checker("admin"))
):
    return await controller.suspend_account(user_id, remark)

@router.post("/users/{user_id}/reactivate")
async def reactivate_user(user_id: str, current_user: dict = Depends(role_checker("admin"))):
    return await controller.reactivate_account(user_id)

# -----------------------------
# New beginner-friendly endpoints
# -----------------------------

@router.get("/dashboard")
async def get_dashboard(current_user: dict = Depends(role_checker("admin"))):
    return await controller.get_dashboard_stats()

@router.get("/gigs")
async def get_gigs_for_moderation(
    status_filter: str = Query("pending", enum=["pending", "all"]),
    limit: int = Query(50, gt=1, le=200),
    current_user: dict = Depends(role_checker("admin")),
):
    return await controller.list_gigs_for_moderation(status_filter=status_filter, limit=limit)

@router.patch("/gigs/{gig_id}/approve")
async def approve_gig(gig_id: str, current_user: dict = Depends(role_checker("admin"))):
    return await controller.moderate_gig(gig_id, "approved")

@router.patch("/gigs/{gig_id}/reject")
async def reject_gig(gig_id: str, current_user: dict = Depends(role_checker("admin"))):
    return await controller.moderate_gig(gig_id, "rejected")

@router.get("/orders")
async def list_orders(
    limit: int = Query(50, gt=1, le=200),
    current_user: dict = Depends(role_checker("admin")),
):
    return await controller.list_orders(limit=limit)

@router.get("/payments/summary")
async def payments_summary(current_user: dict = Depends(role_checker("admin"))):
    return await controller.payments_summary()
