from fastapi import APIRouter, Depends, Query

from Controllers.GigController import Gigcontroller
from core.checker import role_checker
from schema.gigSchema import GigSchema

router = APIRouter(prefix="/gigs", tags=["Gigs"])
controller = Gigcontroller()


@router.post("/")
async def create_gig(data: GigSchema, current_user: dict = Depends(role_checker("freelancer"))):
    gig_id = await controller.create_gig(data.dict(), str(current_user["_id"]))
    return {"gig_id": gig_id}


@router.get("/")
async def get_all_gigs(
    sort_by: str = Query("rating", enum=["rating", "price", "distance"]),
    limit: int = Query(10, gt=0, le=100)
):
    return await controller.get_all_gigs(sort_by=sort_by, limit=limit)


@router.get("/my")
async def get_my_gigs(current_user: dict = Depends(role_checker("freelancer"))):
    return await controller.get_gigs_by_freelancer(str(current_user["_id"]))


@router.get("/{gig_id}")
async def get_gig_by_id(gig_id: str):
    return await controller.get_gig_by_id(gig_id)


@router.put("/{gig_id}")
async def update_gig(gig_id: str, data: GigSchema, current_user: dict = Depends(role_checker("freelancer"))):
    return await controller.update_gig(gig_id, data.dict(), str(current_user["_id"]))


@router.delete("/{gig_id}",)
async def delete_gig(gig_id: str, current_user: dict = Depends(role_checker(["freelancer", "admin"]))):
    return await controller.delete_gig(gig_id, str(current_user["_id"]))
