import asyncio
import logging

# Set up a basic logger for the background worker
logger = logging.getLogger("order_queue")

class Node:
    """Linked list node for the custom FIFO queue."""
    def __init__(self, data: dict):
        self.data = data
        self.next = None

class CustomFIFOQueue:
    """
    A custom asynchronous FIFO queue implemented via a linked list.
    It uses asyncio.Event() to efficiently wait for new items without blocking.
    """
    def __init__(self):
        self.head = None
        self.tail = None
        self._count = 0
        self._item_available = asyncio.Event()

    def enqueue(self, item: dict):
        """Add an item to the end of the linked list."""
        new_node = Node(item)
        if self.tail is None:
            self.head = new_node
            self.tail = new_node
        else:
            self.tail.next = new_node
            self.tail = new_node
        
        self._count += 1
        # Signal that an item is now available for the worker
        self._item_available.set()

    async def dequeue(self) -> dict:
        """
        Remove and return an item from the front of the list.
        If empty, it waits asynchronously until an item is enqueued.
        """
        # Wait asynchronously until at least one item is in the queue
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
        """Check if the queue is empty."""
        return self.head is None

    def size(self) -> int:
        """Return the current number of items in the queue."""
        return self._count


# Global singleton instance of our queue
order_queue = CustomFIFOQueue()


async def process_order_acceptance_worker():
    """
    Background worker that continuously monitors the CustomFIFOQueue 
    and handles order assignment sequentially to prevent race conditions.
    """
    # Lazy import to avoid circular dependency
    from Service.OrderService import OrderService
    
    order_service = OrderService()
    logger.info("Order acceptance background worker started.")
    
    while True:
        try:
            # This will wait (yield control) until an item is successfully dequeued
            task = await order_queue.dequeue()
            
            order_id = task.get("order_id")
            freelancer_id = task.get("freelancer_id")
            
            logger.info(f"Processing acceptance request: Order {order_id} by Freelancer {freelancer_id}")
            
            # Delegate to the atomic assignment logic in the service layer
            await order_service.assign_order_atomically(order_id, freelancer_id)
            
        except asyncio.CancelledError:
            logger.info("Order worker successfully stopped.")
            break
        except Exception as e:
            # Catching general exceptions so the worker does not crash and die
            logger.error(f"Error processing order task: {e}")
