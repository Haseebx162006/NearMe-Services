from Service.DeliveryService import DeliveryService
from fastapi import HTTPException, UploadFile


class DeliveryController:
    def __init__(self):
        self.service = DeliveryService()

    async def submit_delivery(
        self,
        order_id: str,
        freelancer_id: str,
        files: list[UploadFile],
        message: str = "",
    ):
        return await self.service.submit_delivery(order_id, freelancer_id, files, message)

    async def accept_delivery(self, order_id: str, customer_id: str):
        return await self.service.accept_delivery(order_id, customer_id)

    async def reject_delivery(self, order_id: str, customer_id: str, reason: str = ""):
        return await self.service.reject_delivery(order_id, customer_id, reason)
