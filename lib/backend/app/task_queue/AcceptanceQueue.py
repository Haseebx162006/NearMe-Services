import asyncio
import logging


logger = logging.getLogger("order_queue")

class Node:
    def __init__(self, data: dict):
        self.data = data
        self.next = None

class CustomFIFOQueue:
    
    def __init__(self):
        self.head = None
        self.tail = None
        self._count = 0
        self._item_available = asyncio.Event()

    def enqueue(self, item: dict):
    
        new_node = Node(item)
        if self.tail is None:
            self.head = new_node
            self.tail = new_node
        else:
            self.tail.next = new_node
            self.tail = new_node
        
        self._count += 1
        #
        self._item_available.set()

    async def dequeue(self) -> dict:
        
        while self.is_empty():
            self._item_available.clear()
            await self._item_available.wait()

        # Extract data from the head node
        node = self.head
        self.head = node.next
        
        if self.head is None:
            self.tail = None
            
        self._count -= 1
        return node.data

    def is_empty(self) -> bool:
        
        return self.head is None

    def size(self) -> int:
        
        return self._count



order_queue = CustomFIFOQueue()


async def process_order_acceptance_worker():
   
    # Lazy import to avoid circular dependency
    from Service.OrderService import OrderService
    
    order_service = OrderService()
    logger.info("Order acceptance background worker started.")
    
    while True:
        try:
            
            task = await order_queue.dequeue()
            
            order_id = task.get("order_id")
            freelancer_id = task.get("freelancer_id")
            
            logger.info(f"Processing acceptance request: Order {order_id} by Freelancer {freelancer_id}")
            
           
            await order_service.assign_order_atomically(order_id, freelancer_id)
            
        except asyncio.CancelledError:
            logger.info("Order worker successfully stopped.")
            break
        except Exception as e:
            # Catching general exceptions so the worker does not crash and die
            logger.error(f"Error processing order task: {e}")
