from fastapi import APIRouter, Form, HTTPException, UploadFile, File, Depends
from fastapi.responses import StreamingResponse
from ..models.animations_model import AnimationCreate
from ..repositories.animation_repository import AnimationRepository
from ..utils.dependencies import get_current_user
from ..schemas.animation_schemas import AnimationCreate, AnimationResponse
from typing import Annotated, List
from io import BytesIO

router = APIRouter()

@router.post("/", response_model=AnimationResponse)
async def create_animation(
    animation_name: Annotated[str, Form()],
    animation_description: Annotated[str, Form()],
    is_public: Annotated[bool, Form()],
    physical_width: Annotated[int, Form()],
    physical_height: Annotated[int, Form()],
    file: UploadFile = File(...),
    user = Depends(get_current_user)
):
    try:
        # Parse data into the AnimationCreate structure
        animation = AnimationCreate(
            animationName=animation_name,
            animationDescription=animation_description,
            isPublic=is_public,
            physicalWidth=physical_width,
            physicalHeight=physical_height,
        )

        # Save file
        file_id = await AnimationRepository.save_file_to_gridfs(file)

        # Save animation metadata
        animation_data = animation.dict()
        animation_data["author_id"] = user["id"]
        animation_data["animationFileId"] = str(file_id)

        created_animation = AnimationRepository.create_animation(animation_data)
        return created_animation
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    

@router.get("/", response_model=List[AnimationResponse])
async def get_animations():
    animations = AnimationRepository.get_all_animations()
    return animations

@router.get("/{animation_id}", response_model=AnimationResponse)
async def get_animation(animation_id: str):
    animation = AnimationRepository.get_animation_by_id(animation_id)
    if not animation:
        raise HTTPException(status_code=404, detail="Animation not found")
    return animation

@router.get("/{animation_id}/file")
async def get_animation_file(animation_id: str):
    animation = AnimationRepository.get_animation_by_id(animation_id)
    if not animation:
        raise HTTPException(status_code=404, detail="Animation not found")
    
    file_id = animation.get("animationFileId")
    if not file_id:
        raise HTTPException(status_code=404, detail="Animation file not found")
    
    try:
        # Retrieve the file from GridFS
        grid_out = await AnimationRepository.get_animation_file(file_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail="Error retrieving the file")
    
    if not grid_out:
        raise HTTPException(status_code=404, detail="File not found in storage")
    
    file_stream = BytesIO(grid_out.read())
    return StreamingResponse(
        file_stream,
        media_type=grid_out.content_type or "application/octet-stream",
        headers={
            "Content-Disposition": f"attachment; filename={grid_out.filename}"
        }
    )