from schema.OrderSchema import CreateOrderSchema
from fastapi import HTTPException, status
from core.database import db
from bson import ObjectId
from utils.Pyobject import validate_object_id

class OrderService:
    def __init__(self):
        self.db = db

    def _serialize_order(self, order: dict) -> dict:
        serialized = dict(order )
        serialized["_id"] = str(serialized["_id"])
        return serialized
    
    async def create_order(self, order_data:CreateOrderSchema):
        
        # Logic to create an order in the database
        
        payload = dict(order_data)
        if not payload:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid order data")
        
        Order = await self.db.orders.insert_one(payload)
        return str(Order.inserted_id)
     
     
    async def get_order_by_id(self, order_id: str):
        # Logic to retrieve an order by its ID from the database
        
        order = await self.db.orders.find_one({"_id": validate_object_id(order_id)})
        if not order:
            raise HTTPException(status_code=404, detail="Order not found")
        return self._serialize_order(order)
    
    
    async def get_orders_by_user(self, user_id: str):
        # Logic to retrieve all orders for a specific user from the database
        
        orders = await self.db.orders.find({"user_id": user_id}).to_list(length=100)
        if not orders:
            raise HTTPException(status_code=404, detail="No orders found for this user")
        return [self._serialize_order(order) for order in orders]
    
    async def delete_order(self, order_id: str):
        # Logic to delete an order by its ID from the database
        
        order_object_id = validate_object_id(order_id)
        order = await self.db.orders.find_one({"_id": order_object_id})
        
        if order is None:
            raise HTTPException(status_code=404, detail="Order not found")
        
        await self.db.orders.delete_one({"_id": order_object_id})
        return {"message": "Order deleted successfully"}
    
    async def update_order(self, order_id: str, order_data: dict):
        # Logic to update an order by its ID in the database
        
        order_object_id = validate_object_id(order_id)
        order = await self.db.orders.find_one({"_id": order_object_id})
        
        if order is None:
            raise HTTPException(status_code=404, detail="Order not found")
        
        update_data = dict(order_data)
        if not update_data:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid order data")
        
        update_data.pop("_id", None)
        await self.db.orders.update_one({"_id": order_object_id}, {"$set": update_data})
        return {"message": "Order updated successfully"}