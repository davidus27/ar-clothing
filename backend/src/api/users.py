from typing import List
from fastapi import APIRouter, HTTPException
from ..models.user import UserCreate, UserResponse, UserUpdate
from ..models.garments import Garment, GarmentCreate
from ..repositories.user_repository import UserRepository
from ..utils.security import create_access_token

router = APIRouter()

@router.get("/", response_model=list[UserResponse])
async def get_all_users():
    users = UserRepository.get_all_users()
    return users

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(user_id: str):
    user = UserRepository.get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.post("/", response_model=UserCreate)
async def create_user(user: UserResponse):
    existing_user = UserRepository.get_user_by_name(user.name)
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    
    created_user = UserRepository.create_user(user.model_dump(by_alias=True))
    token = create_access_token(created_user['id'])
    created_user['token'] = token
    return created_user



@router.put("/{user_id}", response_model=bool)
async def update_user(user_id: str, user_update: UserUpdate):
    updated = UserRepository.update_user(user_id, user_update.model_dump(exclude_unset=True))
    if not updated:
        raise HTTPException(status_code=404, detail="User not found")
    return updated

@router.delete("/{user_id}", response_model=bool)
async def delete_user(user_id: str):
    deleted = UserRepository.delete_user(user_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="User not found")
    return deleted

@router.delete("/", response_model=bool)
async def delete_all_users():
    return UserRepository.delete_all_users()


# garments

@router.get("/{user_id}/garments", response_model=List[Garment])
async def get_user_garments(user_id: str):
    user = UserRepository.get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user["garments"]

@router.post("/{user_id}/garments", response_model=Garment)
async def add_garment_to_user(user_id: str, garment: GarmentCreate):
    updated_user = UserRepository.add_garment_to_user(user_id, garment)
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found")
    return garment