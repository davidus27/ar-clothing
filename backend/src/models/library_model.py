from pydantic import BaseModel
from typing import List, Optional

class Library(BaseModel):
    user_id: str
    animation_ids: List[str] = []