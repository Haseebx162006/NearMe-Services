from Service.DisputeService import DisputeService


class DisputeController:
    def __init__(self):
        self.service = DisputeService()

    async def create_dispute(self, order_id: str, customer_id: str, reason: str):
        return await self.service.create_dispute(order_id, customer_id, reason)

    async def resolve_dispute(self, order_id: str, decision: str, resolution_note: str = ""):
        return await self.service.resolve_dispute(order_id, decision, resolution_note)

    async def get_disputes(self, status_filter: str = "all"):
        return await self.service.get_disputes(status_filter)
