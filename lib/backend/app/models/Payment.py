from pydantic import BaseModel, Field
from typing import Optional, Literal
from datetime import datetime
from utils.Pyobject import PyObjectId


class Payment(BaseModel):

    id: Optional[PyObjectId] = Field(alias="_id", default=None)

    order_id: PyObjectId
    customer_id: PyObjectId
    freelancer_id: PyObjectId

    stripe_payment_intent_id: str

    amount: float

    
    platform_fee_percent: float = 5.0

    platform_fee_amount: Optional[float] = None
    freelancer_payout: Optional[float] = None

    status: Literal[
        "pending",
        "succeeded",
        "held",
        "released",
        "refunded"
    ] = "pending"

    # Escrow safety flags
    is_held: bool = False
    is_released: bool = False

    # Approval tracking
    customer_confirmed: bool = False
    freelancer_confirmed: bool = False

    created_at: datetime = Field(default_factory=datetime.utcnow)
    released_at: Optional[datetime] = None