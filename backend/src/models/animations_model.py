from pydantic import BaseModel, Field
from typing import Optional
from bson import ObjectId
from datetime import datetime

class AnimationBase(BaseModel):
    animationName: str = ""
    animationDescription: str = ""
    isPublic: bool = False
    physicalWidth: int
    physicalHeight: int
    # animationFileId: Optional[str] = None  # Reference to GridFS file ID
    # thumbnailFileId: Optional[str] = None  # Reference to GridFS thumbnail file ID


class AnimationRequest(AnimationBase):
    pass

class AnimationCreate(AnimationRequest):
    id: str
    author_id: str  # Reference to the User who created the animation
    created_at: str  # Creation date
