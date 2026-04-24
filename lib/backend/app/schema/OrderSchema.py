from pydantic import BaseModel, Field, ConfigDict
from typing import Literal, Optional
from datetime import datetime, timezone

from ..utils.Pyobject import PyObjectId
from ..utils.Constants import constant


class BaseOrderSchema(BaseModel):
    gig_id: PyObjectId

    amount: float = Field(gt=0)

    requirements: Optional[str] = None
    chat_id: Optional[PyObjectId] = None

    status: Literal[
        "pending",
        "accepted",
        "rejected",
        "in_progress",
        "completed",
        "cancelled"
    ] = "pending"

    platform_fee: float = Field(default_factory=lambda: constant.PLATFORM_FEE)

    payment_status: Literal[
        "held",
        "released",
        "refunded"
    ] = "held"

    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc)
    )



class CreateOrderSchema(BaseModel):
    gig_id: PyObjectId
    freelancer_id: PyObjectId
    customer_id: PyObjectId

    amount: float = Field(gt=0)

    requirements: Optional[str] = None
    chat_id: Optional[PyObjectId] = None



class UpdateOrderSchema(BaseModel):
    status: Optional[Literal[
        "pending",
        "accepted",
        "rejected",
        "in_progress",
        "completed",
        "cancelled"
    ]] = None

    payment_status: Optional[Literal[
        "held",
        "released",
        "refunded"
    ]] = None

    completed_at: Optional[datetime] = None



class OrderResponseSchema(BaseOrderSchema):
    id: PyObjectId
    freelancer_id: PyObjectId
    customer_id: PyObjectId

    model_config = ConfigDict(
        arbitrary_types_allowed=True,
        json_encoders={
            PyObjectId: str
        }
    )