from typing import List
from fastapi import APIRouter, HTTPException, Request
from ..models.garments_model import Garment, GarmentCreate
from ..repositories.user_repository import UserRepository
from ..utils.security import create_access_token

from .users import router as user_router

# Garments Endpoints
@user_router.get("/{user_id}/garments", response_model=List[Garment])
async def get_user_garments(user_id: str):
    user = UserRepository.get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user["garments"]

@user_router.post("/{user_id}/garments", response_model=Garment)
async def add_garment_to_user(user_id: str, garment: GarmentCreate, request: Request):
    updated_user = UserRepository.add_garment_to_user(user_id, garment)
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    garment_data = garment.model_dump()
    garment_data['links'] = [
        {"rel": "self", "href": str(request.url_for("get_user_garments", user_id=user_id))}
    ]
    return garment_data