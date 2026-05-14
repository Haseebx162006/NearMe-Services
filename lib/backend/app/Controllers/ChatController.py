from fastapi import HTTPException, status
from Service.ChatService import ChatService
from schema.chat_schema import ChatStartRequest, SendMessageRequest

class ChatController:
    def __init__(self):
        self.service = ChatService()

    async def start_conversation(self, current_user_id: str, request: ChatStartRequest):
        try:
            return await self.service.get_or_create_conversation(
                customer_id=current_user_id,
                freelancer_id=request.freelancer_id,
                gig_id=request.gig_id
            )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to start conversation: {str(e)}"
            )

    async def send_message(self, current_user_id: str, request: SendMessageRequest):
        try:
            return await self.service.save_message(
                conversation_id=request.conversation_id,
                sender_id=current_user_id,
                receiver_id=request.receiver_id,
                text=request.text,
                message_type=request.message_type
            )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to send message: {str(e)}"
            )

    async def get_chat_history(self, conversation_id: str, limit: int = 50, skip: int = 0):
        return await self.service.get_messages(conversation_id, limit, skip)

    async def get_inbox(self, user_id: str):
        return await self.service.get_user_inbox(user_id)

    async def mark_read(self, conversation_id: str, user_id: str):
        return await self.service.mark_as_read(conversation_id, user_id)
