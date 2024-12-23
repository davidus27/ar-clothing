from typing import List
from fastapi import APIRouter, Request, HTTPException, Depends
from ..models.garments_model import Garment, UpdateAnimationId
from ..repositories.garment_repository import GarmentRepository
from ..utils.security import create_access_token
from ..utils.dependencies import get_current_user

router = APIRouter()

@router.get("/", response_model=List[Garment])
async def get_user_garments(user = Depends(get_current_user)):
    garments = GarmentRepository.get_garments_by_user_id(user["id"])
    return garments

@router.delete("/", response_model=bool)
async def delete_all_animations():
    return GarmentRepository.delete_all_garments()


@router.put("/{garment_id}", response_model=Garment)
async def update_garment_animation(garment_id: str, request: UpdateAnimationId, user=Depends(get_current_user)):
    garment = GarmentRepository.get_garment_by_id(garment_id)
    if not garment:
        raise HTTPException(status_code=404, detail="Garment not found")
    if garment.get("user_id") != user["id"]:
        raise HTTPException(status_code=403, detail="You do not own this garment")
    updated = GarmentRepository.update_garment(garment_id, {"animation_id": request.animation_id})
    if not updated:
        raise HTTPException(status_code=400, detail="Failed to update garment")
    return GarmentRepository.get_garment_by_id(garment_id)

@router.put("/{users_id}", response_model=Garment)
async def get_users_garments(users_id: str):
    pass