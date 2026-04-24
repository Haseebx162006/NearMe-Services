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
    platform_fee: float = 4.0
    freelancer_payout: float
    
    status: Literal["pending", "succeeded", "held", "released", "refunded"] = "pending"
    
    created_at: datetime = Field(default_factory=datetime.utcnow)
    released_at: Optional[datetime] = None
