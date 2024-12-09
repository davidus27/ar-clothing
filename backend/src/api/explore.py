from fastapi import APIRouter, HTTPException, Query
from typing import List, Optional
from ..repositories.animation_repository import AnimationRepository
from ..repositories.user_repository import UserRepository
from ..models.user import UserResponse
from ..schemas.animation_schemas import AnimationResponse

router = APIRouter()

@router.get("/animations", response_model=dict)
async def get_animations_for_explore(
    limit: Optional[int] = Query(10, description="Number of animations to retrieve per request"),
    offset: Optional[int] = Query(0, description="Offset for pagination")
):
    animations = AnimationRepository.get_all_animations(limit=limit, offset=offset)
    total_count = AnimationRepository.get_total_count()

    response = {
        "animations": [
            {
                "animation_id": animation["id"],
                "thumbnail": animation.get("thumbnail", ""),
                "author_name": UserRepository.get_user_by_id(animation["author_id"]).get("name", ""),
                "author_profile_image": UserRepository.get_user_by_id(animation["author_id"]).get("imageBase64", ""),
                "title": animation.get("animationName", ""),
                "created_at": animation.get("created_at", ""),
            }
            for animation in animations
        ],
        "pagination": {
            "limit": limit,
            "offset": offset,
            "total_count": total_count
        }
    }
    return response