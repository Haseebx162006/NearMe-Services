from fastapi import APIRouter, Depends, Body, Query
from Controllers.DisputeController import DisputeController
from core.checker import role_checker

router = APIRouter(
    prefix="/disputes",
    tags=["Disputes"],
)

controller = DisputeController()


@router.post("/{order_id}/create")
async def create_dispute(
    order_id: str,
    reason: str = Body(..., embed=True),
    current_user: dict = Depends(role_checker("customer")),
):
    """Customer opens a dispute on a delivered order."""
    customer_id = str(current_user.get("_id") or current_user.get("id"))
    return await controller.create_dispute(order_id, customer_id, reason)


@router.post("/{order_id}/resolve")
async def resolve_dispute(
    order_id: str,
    decision: str = Body(..., embed=True),
    resolution_note: str = Body(default="", embed=True),
    current_user: dict = Depends(role_checker("admin")),
):
    """
    Admin resolves a dispute.
    decision: 'freelancer_wins' or 'customer_wins'
    """
    return await controller.resolve_dispute(order_id, decision, resolution_note)


@router.get("/")
async def list_disputes(
    status_filter: str = Query(default="all", enum=["all", "open", "resolved"]),
    current_user: dict = Depends(role_checker("admin")),
):
    """Admin lists all disputes, optionally filtered by status."""
    return await controller.get_disputes(status_filter)
