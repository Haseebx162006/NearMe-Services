from Service.AnalyticsService import AnalyticService
from bson import ObjectId
from datetime import datetime

class AnalyticsController:
    def __init__(self):
        self.service = AnalyticService()

    def _serialize_value(self, val):
        """Convert non-JSON-serializable types to strings."""
        if isinstance(val, ObjectId):
            return str(val)
        if isinstance(val, datetime):
            return val.isoformat()
        return val

    async def get_freelancer_analytics(self, freelancer_id: str):
        try:
            total_earnings = await self.service.total_earnings(freelancer_id)
            total_orders = await self.service.total_orders(freelancer_id)
            month_earnings = await self.service.current_month_earnings(freelancer_id)
            pending_orders = await self.service.pending_order(freelancer_id)
            recent_orders = await self.service.recent_orders(freelancer_id)

            # Serialize all fields in recent orders for JSON compatibility
            serialized_orders = []
            for order in recent_orders:
                serialized = {
                    k: self._serialize_value(v) for k, v in order.items()
                }
                serialized_orders.append(serialized)

            return {
                'total_earnings': total_earnings,
                'total_orders': total_orders,
                'month_earnings': month_earnings,
                'pending_orders': pending_orders,
                'recent_orders': serialized_orders,
            }
        except Exception as e:
            print(f"[AnalyticsController] Error fetching analytics for {freelancer_id}: {e}")
            # Return safe defaults so the frontend doesn't crash
            return {
                'total_earnings': 0,
                'total_orders': 0,
                'month_earnings': 0,
                'pending_orders': 0,
                'recent_orders': [],
            }
