from Service.AnalyticsService import AnalyticService

class AnalyticsController:
    def __init__(self):
        self.service = AnalyticService()

    async def get_freelancer_analytics(self, freelancer_id: str):
        total_earnings = await self.service.total_earnings(freelancer_id)
        total_orders = await self.service.total_orders(freelancer_id)
        month_earnings = await self.service.current_month_earnings(freelancer_id)
        pending_orders = await self.service.pending_order(freelancer_id)
        recent_orders = await self.service.recent_orders(freelancer_id)

        # Convert ObjectIds to strings for JSON serialization
        for order in recent_orders:
            if '_id' in order:
                order['_id'] = str(order['_id'])

        # Basic dummy values for growth and rating since they aren't in AnalyticService yet
        return {
            'total_earnings': total_earnings,
            'total_orders': total_orders,
            'month_earnings': month_earnings,
            'pending_orders': pending_orders,
            'recent_orders': recent_orders,
            'avg_rating': 4.8, # Placeholder
            'growth': '+15%'   # Placeholder
        }
