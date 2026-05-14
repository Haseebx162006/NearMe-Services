from schema.OrderSchema import CreateOrderSchema
from fastapi import HTTPException, status
from core.database import db
from bson import ObjectId
from utils.Pyobject import validate_object_id

class OrderService:
    def __init__(self):
        self.db = db

    async def _serialize_order(self, order: dict):
        serialized = dict(order)
        serialized["_id"] = str(serialized["_id"])
        
        # Fetch customer name
        if "customer_id" in serialized:
            customer = await self.db.users.find_one({"_id": validate_object_id(serialized["customer_id"])})
            serialized["customer_name"] = customer["name"] if customer else "Unknown Customer"
            
        # Fetch gig title
        if "gig_id" in serialized:
            gig = await self.db.gigs.find_one({"_id": validate_object_id(serialized["gig_id"])})
            serialized["gig_title"] = gig["title"] if gig else "Unknown Gig"
            
        return serialized
    
    async def create_order(self, order_data: dict):
        # Logic to create an order in the database
        if not order_data:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid order data")
        
        # Ensure status is set if not provided
        if "status" not in order_data:
            order_data["status"] = "pending"
            
        import datetime
        order_data["created_at"] = datetime.datetime.utcnow().isoformat()
        
        Order = await self.db.orders.insert_one(order_data)
        return str(Order.inserted_id)
     
     
    async def get_order_by_id(self, order_id: str):
        # Logic to retrieve an order by its ID from the database
        
        order = await self.db.orders.find_one({"_id": validate_object_id(order_id)})
        if not order:
            raise HTTPException(status_code=404, detail="Order not found")
        return self._serialize_order(order)
    
    
    async def get_orders_by_user(self, user_id: str):
        # Logic to retrieve all orders for a specific user from the database
        orders = await self.db.orders.find({
            "$or": [
                {"customer_id": user_id},
                {"freelancer_id": user_id},
            ]
        }).to_list(length=100)
        
        return [await self._serialize_order(order) for order in orders]

    async def get_orders_as_freelancer(self, freelancer_id: str):
        orders = await self.db.orders.find({"freelancer_id": freelancer_id}).to_list(length=100)
        return [await self._serialize_order(order) for order in orders]

    async def get_orders_as_customer(self, customer_id: str):
        orders = await self.db.orders.find({"customer_id": customer_id}).to_list(length=100)
        return [await self._serialize_order(order) for order in orders]
    
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

    async def enqueue_acceptance_request(self, order_id: str, freelancer_id: str):
       
       
        validate_object_id(order_id)
        
        from task_queue.AcceptanceQueue import order_queue
        
        # Enqueue the request
        order_queue.enqueue({
            "order_id": order_id,
            "freelancer_id": freelancer_id
        })
        
        return {"message": "Order acceptance request added to queue successfully"}

    async def assign_order_atomically(self, order_id: str, freelancer_id: str):
       
        order_object_id = validate_object_id(order_id)
        
        
        
        updated_order = await self.db.orders.find_one_and_update(
            {"_id": order_object_id, "status": "OPEN"},
            {"$set": {
                "status": "ASSIGNED", 
                "assigned_freelancer_id": freelancer_id
            }},
            return_document=True  # Returns the updated document if successful
        )
        
        if updated_order:
            return True
        else:
            
            return False