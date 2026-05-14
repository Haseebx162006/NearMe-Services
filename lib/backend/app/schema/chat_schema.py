from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class MessageBase(BaseModel):
    conversation_id: str
    text: str
    message_type: str = "text" # text, image, file, etc.

class MessageCreate(MessageBase):
    pass

class MessageResponse(MessageBase):
    id: str = Field(alias="_id")
    sender_id: str
    receiver_id: str
    timestamp: datetime
    status: str = "sent" # sent, delivered, seen

    class Config:
        populate_by_name = True

class ConversationBase(BaseModel):
    customer_id: str
    freelancer_id: str
    gig_id: str

class ConversationCreate(ConversationBase):
    pass

class ConversationResponse(ConversationBase):
    id: str = Field(alias="_id")
    last_message: Optional[str] = None
    unread_count: int = 0
    updated_at: datetime
    
    # Optional fields for UI convenience
    other_user_name: Optional[str] = None
    other_user_image: Optional[str] = None
    gig_title: Optional[str] = None

    class Config:
        populate_by_name = True

class ChatStartRequest(BaseModel):
    freelancer_id: str
    gig_id: str

class SendMessageRequest(BaseModel):
    conversation_id: str
    receiver_id: str
    text: str
    message_type: str = "text"
