from pydantic import BaseModel
from pydantic import BaseModel, Field
from bson import ObjectId

class Garment(BaseModel):
    id: str = Field(default_factory=lambda: str(ObjectId()))
    name: str
    user_id: str # who owns it
    uid: str
    animation_id: str # what animation it should show

class GarmentCreate(BaseModel):
    name: str
    uid: str
    user_id: str
    animation_id: str