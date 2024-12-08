from pydantic import BaseModel
from typing import Optional

# this is basic info for Explore page
class AnimationPreview(BaseModel):
    id: str
    animationName: str
    animationDescription: str
    thumbnailFileId: Optional[str]
    author: 'UserPreview'  # Reference to UserPreview schema

class AnimationDetail(BaseModel):
    id: str
    animationName: str
    animationDescription: str
    isPublic: bool
    physicalWidth: int
    physicalHeight: int
    animationFileId: Optional[str]
    thumbnailFileId: Optional[str]
    author: 'UserDetail'  # Reference to UserDetail schema
    created_at: str

class UserPreview(BaseModel):
    id: str
    name: str
    imageBase64: Optional[str]

class UserDetail(BaseModel):
    id: str
    name: str
    imageBase64: Optional[str]
    description: Optional[str]
