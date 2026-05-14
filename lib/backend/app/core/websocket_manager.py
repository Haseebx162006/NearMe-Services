from typing import Dict, List, Set
from fastapi import WebSocket
import json

class ConnectionManager:
    """
    Manages active WebSocket connections.
    Uses a Dictionary (HashMap) for O(1) user lookup.
    Uses a Set for tracking online users.
    """
    def __init__(self):
        # Dictionary mapping user_id to their active WebSocket connection
        # Data Structure: HashMap (Dict in Python)
        # Time Complexity: O(1) for lookups and additions
        self.active_connections: Dict[str, WebSocket] = {}
        
        # Set of online user IDs
        # Data Structure: Set
        # Time Complexity: O(1) for membership checks
        self.online_users: Set[str] = set()

    async def connect(self, user_id: str, websocket: WebSocket):
        await websocket.accept()
        self.active_connections[user_id] = websocket
        self.online_users.add(user_id)
        print(f"[WS] User {user_id} connected. Total active: {len(self.active_connections)}")

    def disconnect(self, user_id: str):
        if user_id in self.active_connections:
            del self.active_connections[user_id]
        if user_id in self.online_users:
            self.online_users.remove(user_id)
        print(f"[WS] User {user_id} disconnected.")

    async def send_personal_message(self, message: dict, user_id: str):
        """Sends a realtime message to a specific user if they are online."""
        if user_id in self.active_connections:
            websocket = self.active_connections[user_id]
            try:
                await websocket.send_json(message)
                return True
            except Exception as e:
                print(f"[WS] Error sending to {user_id}: {e}")
                self.disconnect(user_id)
                return False
        return False

    async def broadcast(self, message: dict):
        """Broadcasts a message to all connected users."""
        for user_id, connection in self.active_connections.items():
            try:
                await connection.send_json(message)
            except:
                pass

# Global instance of the manager
manager = ConnectionManager()
