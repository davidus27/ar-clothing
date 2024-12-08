from fastapi import APIRouter, HTTPException, UploadFile, File, Depends
from fastapi.responses import StreamingResponse
from datetime import datetime
# from ..models.animations_model import Animation, AnimationCreate
from ..repositories.animation_repository import AnimationRepository
from ..utils.dependencies import get_current_user

router = APIRouter()

# @router.get("/", response_model=list[Animation])

# src/api/explore.py

@router.get("/{id}")
async def get_explore_item(id: str):
    pass

@router.post("/")
async def create_explore_item(item: dict):
    pass

@router.put("/{id}")
async def update_explore_item(id: str, item: dict):
    pass