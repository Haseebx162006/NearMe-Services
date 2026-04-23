from ..Service.GigService import GigService
from ..core.checker import ensure_role


class GigController:
    def __init__(self):
        self.service = GigService()
        
        
    async def create_gig(self, data: dict, freelancer_id: str, current_user: dict):
        ensure_role(current_user, "freelancer")
        return await self.service.create_gig(data, freelancer_id)
        
    async def delete_gig(self, gig_id: str, freelancer_id: str, current_user: dict):
        ensure_role(current_user, "freelancer")
        return await self.service.delete_gig(gig_id, freelancer_id)

    async def update_gig(self, gig_id: str, data: dict, freelancer_id: str, current_user: dict):
        ensure_role(current_user, "freelancer")
        return await self.service.update_gig(gig_id, data, freelancer_id)
    
    async def get_gig_by_id(self, gig_id: str):
        return await self.service.get_gig_by_id(gig_id)
    
    
    async def get_gigs_by_freelancer(self, freelancer_id: str, current_user: dict):
        ensure_role(current_user, "freelancer")
        return await self.service.get_gigs_by_freelancer(freelancer_id)
    
    async def get_all_gigs(self):
        return await self.service.get_all_gigs()


# Backward compatibility for existing imports/usages.
class Gigcontroller(GigController):
    pass