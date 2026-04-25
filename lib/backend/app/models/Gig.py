from motor.motor_asyncio import AsyncIOMotorDatabase
from pydantic import BaseModel, Field
from pymongo import IndexModel, TEXT
from typing import Optional, List
from datetime import datetime


class Gig(BaseModel):
    id: Optional[str] = None
    freelancer_id: str
    title: str
    description: str
    price: float = Field(gt=0)
    category: str
    images: List[str] = Field(default_factory=list)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: Optional[datetime] = None
    is_active: bool = True


GIG_INDEXES = [
    IndexModel([("freelancer_id", 1), ("is_active", 1)], name="idx_gigs_freelancer_active"),
    IndexModel([("category", 1), ("is_active", 1), ("created_at", -1)], name="idx_gigs_category_active_created"),
    IndexModel(
        [("title", TEXT), ("description", TEXT)],
        name="idx_gigs_text_title_description",
        default_language="english",
    ),
]


async def ensure_gig_indexes(database: AsyncIOMotorDatabase) -> None:
    await database.gigs.create_indexes(GIG_INDEXES)
    