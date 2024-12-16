from pydantic import BaseModel
from typing import Optional, List
from ..models.links import Link
from ..models.garments_model import Garment

class GarmentCreate(BaseModel):
    name: str
    uid: str

class GarmentResponse(GarmentCreate):
    id: str
    author_id: str
    created_at: Optional[str] = None
    links: List[Link] = []  # Added links field