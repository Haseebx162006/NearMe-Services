from Service.OrderService import OrderService
from core.checker import role_checker
from fastapi import Depends, HTTPException, status

class OrderController:
    def __init__(self):
        self.service = OrderService()
        
        
    async def create_order(self, order_data: dict, current_user: dict):
        if not order_data:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid order data") 
        
        order_data["customer_id"] = str(current_user["_id"])
        return await self.service.create_order(order_data)
        
    async def get_order_by_id(self, order_id: str):
        return await self.service.get_order_by_id(order_id)
    
    
    async def get_orders_by_user(self, user_id: str):
        return await self.service.get_orders_by_user(user_id)
    
    async def get_orders_as_freelancer(self, freelancer_id: str):
        return await self.service.get_orders_as_freelancer(freelancer_id)
    
    async def get_orders_as_customer(self, customer_id: str):
        return await self.service.get_orders_as_customer(customer_id)
    
    
    async def delete_order(self, order_id: str):
        return await self.service.delete_order(order_id)
        
    async def update_order_status(self, order_id: str, new_status: str):
        return await self.service.update_order(order_id, {"status": new_status})

    async def customer_has_pending_review(self, customer_id: str):
        return await self.service.customer_has_pending_review(customer_id)

    async def submit_review(self, order_id: str, customer_id: str, rating: int, comment=None):
        return await self.service.submit_review(order_id, customer_id, rating, comment)
    
    
    
    