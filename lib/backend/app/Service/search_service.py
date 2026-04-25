import math
import re
from typing import Any

from fastapi import HTTPException, status
from pymongo.errors import PyMongoError

from core.database import db
from models.Gig import ensure_gig_indexes
from models.User import ensure_user_indexes
from utils.Pyobject import validate_object_id


class SearchService:
    def __init__(self):
        self.db = db

    async def ensure_indexes(self) -> None:
        # Index definitions live in model files to avoid duplication.
        try:
            await ensure_user_indexes(self.db)
            await ensure_gig_indexes(self.db)
        except PyMongoError as exc:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Unable to initialize search indexes: {str(exc)}",
            ) from exc

    async def _get_user_coordinates(self, user_id: str) -> list[float]:
        # Step 1: Validate and convert user id.
        try:
            user_object_id = validate_object_id(user_id)
        except ValueError as exc:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid user_id",
            ) from exc

        # Step 2: Read only location from the user document.
        user_doc = await self.db.users.find_one(
            {"_id": user_object_id},
            projection={"location": 1},
        )
        if not user_doc:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found",
            )

        # Step 3: Validate location shape.
        location = user_doc.get("location")
        if not isinstance(location, dict):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User location is missing",
            )

        coordinates = location.get("coordinates")
        if location.get("type") != "Point" or not isinstance(coordinates, list) or len(coordinates) != 2:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User location format is invalid",
            )

        longitude, latitude = coordinates
        if not isinstance(longitude, (int, float)) or not isinstance(latitude, (int, float)):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User location coordinates must be numeric",
            )

        return [float(longitude), float(latitude)]

    def _build_gig_filters(self, search: str, category: str) -> dict[str, Any]:
        # Build only the filters that are requested by the client.
        filters: dict[str, Any] = {"is_active": True}

        cleaned_search = search.strip()
        if cleaned_search:
            keyword = re.escape(cleaned_search)
            filters["$or"] = [
                {"title": {"$regex": keyword, "$options": "i"}},
                {"description": {"$regex": keyword, "$options": "i"}},
            ]

        cleaned_category = category.strip()
        if cleaned_category:
            filters["category"] = {
                "$regex": f"^{re.escape(cleaned_category)}$",
                "$options": "i",
            }

        return filters

    async def search_nearby_gigs(
        self,
        user_id: str,
        radius_km: float = 10,
        search: str = "",
        category: str = "",
        page: int = 1,
        page_size: int = 20,
        use_heap_rank: bool = False,
    ) -> dict[str, Any]:
        # This argument is kept only so existing route code still works.
        _ = use_heap_rank

        # Step 1: Basic input validation.
        if radius_km <= 0 or radius_km > 1000:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="radius_km must be between 0 and 1000",
            )

        if page < 1:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="page must be greater than or equal to 1",
            )

        if page_size < 1 or page_size > 100:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="page_size must be between 1 and 100",
            )

        # Step 2: Make sure required indexes exist.
        await self.ensure_indexes()

        # Step 3: Load request user coordinates.
        coordinates = await self._get_user_coordinates(user_id)

        # Step 4: Build filter and pagination values.
        skip = (page - 1) * page_size
        gig_filters = self._build_gig_filters(search=search, category=category)

        # Step 5: Minimal aggregation pipeline.
        pipeline = [
            {
                "$geoNear": {
                    "near": {"type": "Point", "coordinates": coordinates},
                    "distanceField": "distance_meters",
                    "maxDistance": radius_km * 10000.0,
                    "spherical": True,
                    "query": {"role": "freelancer", "is_active": True},
                }
            },
            {
                "$project": {
                    "distance_meters": 1,
                    "freelancer_id": {"$toString": "$_id"},
                }
            },
            {
                "$lookup": {
                    "from": "gigs",
                    "localField": "freelancer_id",
                    "foreignField": "freelancer_id",
                    "as": "gigs",
                }
            },
            {"$unwind": "$gigs"},
            {
                "$replaceRoot": {
                    "newRoot": {
                        "$mergeObjects": [
                            "$gigs",
                            {"distance_meters": "$distance_meters"},
                        ]
                    }
                }
            },
            {"$match": gig_filters},
            {"$sort": {"distance_meters": 1, "created_at": -1}},
            {
                "$facet": {
                    "metadata": [{"$count": "total"}],
                    "items": [{"$skip": skip}, {"$limit": page_size}],
                }
            },
        ]

        # Step 6: Run aggregation.
        try:
            aggregated = await self.db.users.aggregate(pipeline).to_list(length=1)
        except PyMongoError as exc:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to run nearby gig search",
            ) from exc

        # Step 7: Read metadata and paginated records.
        response_bucket = aggregated[0] if aggregated else {"metadata": [], "items": []}
        metadata = response_bucket.get("metadata", [])
        total = metadata[0].get("total", 0) if metadata else 0
        gigs = response_bucket.get("items", [])

        # Step 8: Convert raw Mongo records into API-friendly response.
        result_gigs: list[dict[str, Any]] = []
        for gig in gigs:
            item = dict(gig)
            if "_id" in item:
                item["_id"] = str(item["_id"])

            distance_meters = float(item.pop("distance_meters", 0.0))
            item["distance_km"] = round(distance_meters / 1000.0, 3)
            result_gigs.append(item)

        # Step 9: Build simple summary values.
        unique_freelancers = {
            gig.get("freelancer_id")
            for gig in result_gigs
            if gig.get("freelancer_id")
        }
        nearest_freelancer_km = min(
            (gig["distance_km"] for gig in result_gigs),
            default=None,
        )

        # Step 10: Final paginated response.
        total_pages = math.ceil(total / page_size) if total else 0

        return {
            "page": page,
            "page_size": page_size,
            "total": total,
            "total_pages": total_pages,
            "unique_freelancers": len(unique_freelancers),
            "nearest_freelancer_km": nearest_freelancer_km,
            "items": result_gigs,
        }
