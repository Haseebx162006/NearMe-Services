class AnalyticsController:
    async def get_freelancer_analytics(self, freelancer_id: str):
        # Dummy implementation for beginner-friendly setup
        return {
            'total_views': 2832,
            'avg_rating': 4.8,
            'revenue': 2450.0,
            'growth': '+23%',
            'top_gigs': [
                {'title': 'Professional House Cleaning', 'orders': 124, 'revenue': 1240.0},
                {'title': 'Deep Cleaning Service', 'orders': 89, 'revenue': 890.0},
                {'title': 'Office Cleaning', 'orders': 45, 'revenue': 450.0}
            ]
        }
