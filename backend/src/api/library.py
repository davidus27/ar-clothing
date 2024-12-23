# src/api/library.py
from fastapi import APIRouter, HTTPException, Depends
from typing import List
from ..repositories.library_repository import LibraryRepository
from ..repositories.animation_repository import AnimationRepository
from ..utils.dependencies import get_current_user

router = APIRouter()

@router.post("/{animation_id}", response_model=bool)
async def add_animation_to_library(animation_id: str, user = Depends(get_current_user)):
    # Validate if the animation_id exists
    animation = AnimationRepository.get_animation_by_id(animation_id)
    if not animation:
        raise HTTPException(status_code=404, detail="Animation not found")
    
    added = LibraryRepository.add_animation_to_library(user["id"], animation_id)
    if not added:
        raise HTTPException(status_code=400, detail="Failed to add animation to library")
    return added

@router.get("/list", response_model=List[dict])
async def list_user_library(user = Depends(get_current_user)):
    animation_ids = LibraryRepository.get_animations_by_user_id(user["id"])
    animations = [AnimationRepository.get_animation_by_id(animation_id) for animation_id in animation_ids]
    return filter_none_animations(animations)

@router.get("/owned", response_model=List[dict])
async def list_owned_animations(user = Depends(get_current_user)):
    owned_animations = AnimationRepository.get_animations_by_author_id(user["id"])
    return owned_animations

def filter_none_animations(animations: List[dict]) -> List[dict]:
    return [animation for animation in animations if animation is not None]
