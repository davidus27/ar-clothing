from pydantic import BaseModel
from pydantic import BaseModel, Field
from bson import ObjectId

class Garment(BaseModel):
    id: str = Field(default_factory=lambda: str(ObjectId()))
    name: str
    uid: str

class GarmentCreate(BaseModel):
    name: str
    uid: str