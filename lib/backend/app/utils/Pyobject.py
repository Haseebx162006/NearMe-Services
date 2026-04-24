from bson import ObjectId
from typing import Annotated
from pydantic import BeforeValidator


def validate_object_id(v):
    if isinstance(v, ObjectId):
        return v

    if not ObjectId.is_valid(v):
        raise ValueError("Invalid ObjectId")

    return ObjectId(v)


PyObjectId = Annotated[ObjectId, BeforeValidator(validate_object_id)]