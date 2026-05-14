from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect, Query
from core.access_token import get_current_user
from core.websocket_manager import manager
from Controllers.ChatController import ChatController
from schema.chat_schema import ChatStartRequest, SendMessageRequest
import json

router = APIRouter(prefix="/chat", tags=["Realtime Chat"])
controller = ChatController()

# --- REST Endpoints ---

@router.post("/start")
async def start_conversation(
    request: ChatStartRequest, 
    user: dict = Depends(get_current_user)
):
    """Starts or opens an existing conversation."""
    return await controller.start_conversation(str(user["_id"]), request)

@router.post("/send")
async def send_message(
    request: SendMessageRequest, 
    user: dict = Depends(get_current_user)
):
    """Sends a message via HTTP (useful for fallback or attachments)."""
    return await controller.send_message(str(user["_id"]), request)

@router.get("/inbox")
async def get_inbox(user: dict = Depends(get_current_user)):
    """Fetches the user's chat inbox sorted by latest activity."""
    return await controller.get_inbox(str(user["_id"]))

@router.get("/messages/{conversation_id}")
async def get_messages(
    conversation_id: str, 
    limit: int = 50, 
    skip: int = 0,
    user: dict = Depends(get_current_user)
):
    """Fetches paginated chat history for a conversation."""
    return await controller.get_chat_history(conversation_id, limit, skip)

@router.post("/read/{conversation_id}")
async def mark_read(
    conversation_id: str, 
    user: dict = Depends(get_current_user)
):
    """Marks all messages in a conversation as read."""
    return await controller.mark_read(conversation_id, str(user["_id"]))

# --- WebSocket Endpoint ---

@router.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: str):
    """
    Production-grade WebSocket handler.
    Handles:
    1. Connection acceptance and tracking (ConnectionManager).
    2. Real-time message events (typing, seen, etc.).
    3. Proper cleanup on disconnect.
    """
    await manager.connect(user_id, websocket)
    try:
        while True:
            # Receive data from the client
            data = await websocket.receive_text()
            payload = json.loads(data)
            
            event = payload.get("event")
            event_data = payload.get("data", {})

            if event == "typing":
                # Broadcast typing indicator to the receiver
                target_id = event_data.get("receiver_id")
                await manager.send_personal_message({
                    "event": "typing_indicator",
                    "data": {
                        "sender_id": user_id,
                        "conversation_id": event_data.get("conversation_id"),
                        "is_typing": event_data.get("is_typing", True)
                    }
                }, target_id)

            elif event == "message_seen":
                # Handle read receipts
                target_id = event_data.get("sender_id")
                await manager.send_personal_message({
                    "event": "message_seen_receipt",
                    "data": {
                        "conversation_id": event_data.get("conversation_id"),
                        "seen_by": user_id
                    }
                }, target_id)

    except WebSocketDisconnect:
        manager.disconnect(user_id)
    except Exception as e:
        print(f"[WS] Error in socket for {user_id}: {e}")
        manager.disconnect(user_id)
