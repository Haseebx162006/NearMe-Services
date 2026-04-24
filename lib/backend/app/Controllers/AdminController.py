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
