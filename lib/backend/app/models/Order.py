from pydantic import BaseModel, Field
from typing import Literal, Optional
from datetime import datetime
from ..utils.Pyobject import PyObjectId
from ..utils.Constants import constant


class Order(BaseModel):
    gig_id: PyObjectId
    freelancer_id: PyObjectId
    customer_id: PyObjectId

    status: Literal[
        "pending",
        "accepted",
        "rejected",
        "in_progress",
        "completed",
        "cancelled"
    ] = "pending"

    amount: float = Field(gt=0)

    platform_fee: float = constant.PLATFORM_FEE

    payment_status: Literal[
        "held",
        "released",
        "refunded"
    ] = "held"

    requirements: Optional[str] = None

    chat_id: Optional[PyObjectId] = None

    created_at: datetime = Field(default_factory=datetime.utcnow)
    completed_at: Optional[datetime] = None