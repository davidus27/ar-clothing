from pydantic import BaseModel
from pydantic import BaseModel, Field
from bson import ObjectId
from typing import Optional

class Garment(BaseModel):
    id: Optional[str] = None
    name: str
    user_id: Optional[str] = None # who owns it
    uid: str
    animation_id: Optional[str] = None # what animation it should show

class GarmentCreate(Garment):
    name: str
    uid: str

class UpdateAnimationId(BaseModel):
    animation_id: str