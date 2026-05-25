from pydantic import BaseModel, Field
from typing import Literal, Optional, List
from datetime import datetime, timezone
from pymongo import IndexModel
from motor.motor_asyncio import AsyncIOMotorDatabase
from utils.Pyobject import PyObjectId
from utils.Constants import constant


class Delivery(BaseModel):
    files: List[str] = Field(default_factory=list)
    message: Optional[str] = None
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    version: int = 1


class Order(BaseModel):
    gig_id: PyObjectId
    freelancer_id: PyObjectId
    customer_id: PyObjectId

    status: Literal[
        "pending",
        "accepted",
        "in_progress",
        "delivered",
        "completed",
        "disputed",
        "cancelled"
    ] = "pending"

    amount: float = Field(gt=0)

    platform_fee: float = constant.PLATFORM_FEE

    payment_status: Literal[
        "pending",
        "held",
        "released",
        "refunded"
    ] = "pending"

    stripe_payment_intent_id: Optional[str] = None
    payment_id: Optional[PyObjectId] = None

    deliveries: List[Delivery] = Field(default_factory=list)

    # --- Dispute fields ---
    dispute_status: Literal[
        "none",
        "open",
        "resolved"
    ] = "none"

    dispute_reason: Optional[str] = None
    dispute_resolution: Optional[str] = None

    requirements: Optional[str] = None
    chat_id: Optional[PyObjectId] = None

    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    completed_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


# --- Issue #17: Missing indexes ---
ORDER_INDEXES = [
    IndexModel([("customer_id", 1)], name="idx_orders_customer"),
    IndexModel([("freelancer_id", 1)], name="idx_orders_freelancer"),
    IndexModel([("status", 1), ("dispute_status", 1)], name="idx_orders_status_dispute"),
    IndexModel([("gig_id", 1), ("reviewed", 1)], name="idx_orders_gig_review"),
]


async def ensure_order_indexes(database: AsyncIOMotorDatabase) -> None:
    try:
        await database.orders.create_indexes(ORDER_INDEXES)
    except Exception as e:
        if "IndexKeySpecsConflict" in str(e) or "already exists with different options" in str(e):
            for idx in ORDER_INDEXES:
                try:
                    await database.orders.drop_index(idx.document["name"])
                except Exception:
                    pass
            await database.orders.create_indexes(ORDER_INDEXES)
        else:
            raise e