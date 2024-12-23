from pydantic import BaseModel
from fastapi import UploadFile, File
from typing import Optional


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
    author_id: str 
    createdAt: str
    file: UploadFile = File(...)
    thumbnail: str
