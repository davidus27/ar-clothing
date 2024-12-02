from pydantic import BaseModel
from typing import Optional
from pydantic import BaseModel, Field
from bson import ObjectId
from typing_extensions import Annotated
from pydantic.functional_validators import BeforeValidator


PyObjectId = Annotated[str, BeforeValidator(str)]

# Custom Pydantic model to handle ObjectId serialization
class UserBase(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    name: str
    email: str

    class Config:
        # Add a custom encoder for ObjectId to be converted into a string
        json_encoders = {
            ObjectId: str  # Converts ObjectId to a string
        }

class UserCreate(UserBase):
    pass


class UserUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    imageBase64: Optional[str] = None


class UserResponse(UserBase):
    pass
