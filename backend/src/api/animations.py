from fastapi import APIRouter, HTTPException, UploadFile, File
from fastapi.responses import StreamingResponse
from ..models.animations import Animation, AnimationCreate
from ..repositories.animation_repository import AnimationRepository

router = APIRouter()

@router.post("/", response_model=Animation)
async def create_animation(
    animationName: str,
    animationDescription: str,
    isPublic: bool,
    physicalWidth: int,
    physicalHeight: int,
    selectedGarment: str,
    animationFile: UploadFile = File(...)
):
    # Save the file to GridFS
    file_id = await AnimationRepository.save_file_to_gridfs(animationFile)

    # Create the animation data with the file reference
    animation_data = AnimationCreate(
        animationName=animationName,
        animationDescription=animationDescription,
        isPublic=isPublic,
        physicalWidth=physicalWidth,
        physicalHeight=physicalHeight,
        selectedGarment=selectedGarment,
        animationFileId=str(file_id)
    )
    return AnimationRepository.create_animation(animation_data)

@router.get("/{animation_id}/file")
async def get_animation_file(animation_id: str):
    animation = AnimationRepository.get_animation_by_id(animation_id)
    if not animation or not animation.get('animationFileId'):
        raise HTTPException(status_code=404, detail="Animation or file not found")

    grid_out = await AnimationRepository.get_animation_file(animation['animationFileId'])
    return StreamingResponse(grid_out, media_type=grid_out.content_type)