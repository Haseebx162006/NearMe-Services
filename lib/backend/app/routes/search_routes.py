from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel, ConfigDict, Field

from core.access_token import get_current_user
from Service.search_service import SearchService

router = APIRouter(prefix="/search", tags=["Search"])
service = SearchService()


class NearbyGigItem(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    gig_id: str = Field(alias="_id")
    freelancer_id: str
    title: str
    description: str
    category: str
    price: float
    images: list[str] = Field(default_factory=list)
    is_active: bool = True
    distance_km: float
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class NearbyGigSearchResponse(BaseModel):
    page: int
    page_size: int
    total: int
    total_pages: int
    unique_freelancers: int
    nearest_freelancer_km: Optional[float] = None
    items: list[NearbyGigItem]


@router.get("/nearby-gigs", response_model=NearbyGigSearchResponse)
async def search_nearby_gigs(
    radius_km: float = Query(10, gt=0, le=100),
    search: str = Query("", max_length=100),
    category: str = Query("", max_length=60),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    use_heap_rank: bool = Query(False),
    current_user: dict = Depends(get_current_user),
):
    return await service.search_nearby_gigs(
        user_id=str(current_user["_id"]),
        radius_km=radius_km,
        search=search,
        category=category,
        page=page,
        page_size=page_size,
        use_heap_rank=use_heap_rank,
    )
