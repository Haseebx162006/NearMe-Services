

from pydantic import BaseModel, Field


class GigSchema(BaseModel):
    title: str
    description: str
    price: float
    freelancer_id: str
    category: str
    images: list[str] = Field(default_factory=list)
    