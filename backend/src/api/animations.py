from fastapi import APIRouter, HTTPException, UploadFile, File, Depends
from fastapi.responses import StreamingResponse
from datetime import datetime
from ..models.animations_model import AnimationRequest, AnimationCreate
from ..repositories.animation_repository import AnimationRepository
from ..utils.dependencies import get_current_user

router = APIRouter()

@router.post("/", response_model=AnimationCreate)
async def create_animation(animationRequest: AnimationRequest):
    pass

@router.get("/{animation_id}/file")
async def get_animation_file(animation_id: str):
    pass