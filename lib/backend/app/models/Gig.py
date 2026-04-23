from pydantic import BaseModel, Field
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