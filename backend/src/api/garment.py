from typing import List
from fastapi import APIRouter, Request, HTTPException
from ..models.garments_model import Garment, UpdateAnimationId
from ..repositories.garment_repository import GarmentRepository
from ..utils.security import create_access_token

router = APIRouter()

@router.get("/", response_model=List[Garment])
async def get_all_garments():
    users = GarmentRepository.get_all_garments()
    return users

@router.delete("/", response_model=bool)
async def delete_all_animations():
    return GarmentRepository.delete_all_garments()

@router.put("/{garment_id}", response_model=Garment)
async def update_garment_animation_id(garment_id: str, request: UpdateAnimationId):
    updated = GarmentRepository.update_garment(garment_id, {"animation_id": request.animation_id})
    if not updated:
        raise HTTPException(status_code=404, detail="Garment not found")
    return GarmentRepository.get_garment_by_id(garment_id)