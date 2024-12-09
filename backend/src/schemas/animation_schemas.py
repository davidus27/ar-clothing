# src/schemas/animation_schemas.py
from pydantic import BaseModel
from typing import Optional

class AnimationCreate(BaseModel):
    animationName: str
    animationDescription: str
    isPublic: bool
    physicalWidth: int
    physicalHeight: int

class AnimationResponse(AnimationCreate):
    id: str
    author_id: str
    animationFileId: Optional[str] = None
    created_at: Optional[str] = None