from pydantic import BaseModel
from typing import List, Optional

class LinkedGarmentData(BaseModel):
    id: str
    name: str
    uid: str

class UserData(BaseModel):
    id: str
    imageBase64: Optional[str]
    name: str
    description: Optional[str]
    joinedDate: str

class UserResponse(BaseModel):
    user: UserData
    garments: List[LinkedGarmentData]
