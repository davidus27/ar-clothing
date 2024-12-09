from pydantic import BaseModel, Field
from typing import Optional
from bson import ObjectId
from fastapi import APIRouter, HTTPException, UploadFile, File, Depends


class AnimationBase(BaseModel):
    animationName: str = ""
    animationDescription: str = ""
    isPublic: bool = False
    physicalWidth: int
    physicalHeight: int
    # add here the field for file upload

class AnimationRequest(AnimationBase):
    pass

class AnimationCreate(AnimationRequest):
    id: str
    author_id: str  # Reference to the User who created the animation
    created_at: str  # Creation date
    file: UploadFile = File(...)
