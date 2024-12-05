from pydantic import BaseModel, Field
from typing import Optional
from bson import ObjectId

class AnimationBase(BaseModel):
    animationName: str = ""
    animationDescription: str = ""
    isPublic: bool = False
    physicalWidth: int
    physicalHeight: int
    animationFileId: Optional[str] = None  # Reference to GridFS file ID

    # thumbnail files
    thumbnailFileId: Optional[str] = None

class AnimationCreate(AnimationBase):
    pass

class Animation(AnimationBase):
    id: str = Field(default_factory=lambda: str(ObjectId()))