from Service.AdminServices import AdminService

class AdminController:
    def __init__(self):
        self.service = AdminService()

    async def get_all_users(self):
        return await self.service.get_all_users()

    async def suspend_account(self, user_id: str, remark: str):
        return await self.service.suspend_account(user_id, remark)

    async def reactivate_account(self, user_id: str):
        return await self.service.reactivate_account(user_id)

    async def get_dashboard_stats(self):
        return await self.service.get_dashboard_stats()

    async def list_gigs_for_moderation(self, status_filter: str = "pending", limit: int = 50):
        return await self.service.list_gigs_for_moderation(status_filter=status_filter, limit=limit)

    async def moderate_gig(self, gig_id: str, new_status: str):
        return await self.service.moderate_gig(gig_id, new_status)

    async def list_orders(self, limit: int = 50):
        return await self.service.list_orders(limit=limit)

    async def payments_summary(self):
        return await self.service.payments_summary()
