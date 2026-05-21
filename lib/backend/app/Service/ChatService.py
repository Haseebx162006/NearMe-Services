from datetime import datetime, timezone
from typing import List, Optional
from bson import ObjectId
from core.database import db
from core.websocket_manager import manager
from utils.Pyobject import validate_object_id

class ChatService:
    def __init__(self):
        self.db = db

    async def get_or_create_conversation(self, customer_id: str, freelancer_id: str, gig_id: str):
        
        existing = await self.db.conversations.find_one({
            "customer_id": customer_id,
            "freelancer_id": freelancer_id,
            "gig_id": gig_id
        })

        if existing:
            existing["_id"] = str(existing["_id"])
            return existing

        new_conversation = {
            "customer_id": customer_id,
            "freelancer_id": freelancer_id,
            "gig_id": gig_id,
            "last_message": "",
            "unread_count": 0,
            "updated_at": datetime.now(timezone.utc)
        }

        result = await self.db.conversations.insert_one(new_conversation)
        new_conversation["_id"] = str(result.inserted_id)
        return new_conversation

    async def save_message(self, conversation_id: str, sender_id: str, receiver_id: str, text: str, message_type: str = "text"):
        
        message_doc = {
            "conversation_id": conversation_id,
            "sender_id": sender_id,
            "receiver_id": receiver_id,
            "text": text,
            "message_type": message_type,
            "status": "sent",
            "timestamp": datetime.now(timezone.utc)
        }

        result = await self.db.messages.insert_one(message_doc)
        message_doc["_id"] = str(result.inserted_id)

        # Update conversation meta
        await self.db.conversations.update_one(
            {"_id": ObjectId(conversation_id)},
            {
                "$set": {
                    "last_message": text,
                    "updated_at": datetime.now(timezone.utc)
                },
                "$inc": {"unread_count": 1}
            }
        )

        
        ws_payload = {
            "event": "message_received",
            "data": message_doc
        }
        await manager.send_personal_message(ws_payload, receiver_id)

        return message_doc

    async def get_messages(self, conversation_id: str, limit: int = 50, skip: int = 0):
        
        cursor = self.db.messages.find({"conversation_id": conversation_id}) \
            .sort("timestamp", -1) \
            .skip(skip) \
            .limit(limit)
        
        messages = await cursor.to_list(length=limit)
        for msg in messages:
            msg["_id"] = str(msg["_id"])
        
        # Reverse to show in chronological order on UI
        return messages[::-1]

    async def get_user_inbox(self, user_id: str):
       
        pipeline = [
            {
                "$match": {
                    "$or": [
                        {"customer_id": user_id},
                        {"freelancer_id": user_id}
                    ]
                }
            },
            {"$sort": {"updated_at": -1}}, # Latest active chats first
            {
                "$addFields": {
                    "other_user_id": {
                        "$cond": {
                            "if": {"$eq": ["$customer_id", user_id]},
                            "then": "$freelancer_id",
                            "else": "$customer_id"
                        }
                    },
                    "gig_oid": {"$toObjectId": "$gig_id"}
                }
            },
            {
                "$addFields": {
                    "other_user_oid": {"$toObjectId": "$other_user_id"}
                }
            },
            # Lookup other user info
            {
                "$lookup": {
                    "from": "users",
                    "localField": "other_user_oid",
                    "foreignField": "_id",
                    "as": "other_user"
                }
            },
            {"$unwind": "$other_user"},
            # Lookup gig info
            {
                "$lookup": {
                    "from": "gigs",
                    "localField": "gig_oid",
                    "foreignField": "_id",
                    "as": "gig_info"
                }
            },
            {"$unwind": "$gig_info"},
            {
                "$project": {
                    "_id": {"$toString": "$_id"},
                    "customer_id": 1,
                    "freelancer_id": 1,
                    "gig_id": 1,
                    "last_message": 1,
                    "unread_count": 1,
                    "updated_at": 1,
                    "other_user_name": "$other_user.name",
                    "other_user_image": "$other_user.profile_picture",
                    "gig_title": "$gig_info.title"
                }
            }
        ]

        inbox = await self.db.conversations.aggregate(pipeline).to_list(length=100)
        return inbox

    async def mark_as_read(self, conversation_id: str, user_id: str):
        
        await self.db.conversations.update_one(
            {"_id": ObjectId(conversation_id)},
            {"$set": {"unread_count": 0}}
        )
        
        # Update message status to 'seen' for this conversation (simplified)
        await self.db.messages.update_many(
            {"conversation_id": conversation_id, "receiver_id": user_id, "status": {"$ne": "seen"}},
            {"$set": {"status": "seen"}}
        )
        return True
