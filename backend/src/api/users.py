from typing import List
from fastapi import APIRouter, HTTPException, Request
from ..models.user import UserCreate, UserResponse, UserUpdate
from ..models.garments_model import Garment, GarmentCreate
from ..repositories.user_repository import UserRepository
from ..utils.security import create_access_token

router = APIRouter()

@router.get("/", response_model=List[UserResponse])
async def get_all_users(request: Request):
    users = UserRepository.get_all_users()
    for user in users:
        user['links'] = [
            {"rel": "self", "href": str(request.url_for("get_user", user_id=user['id']))},
            {"rel": "garments", "href": str(request.url_for("get_user_garments", user_id=user['id']))}
        ]
    return users

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(user_id: str, request: Request):
    user = UserRepository.get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    user['links'] = [
        {"rel": "self", "href": str(request.url)},
        {"rel": "garments", "href": str(request.url_for("get_user_garments", user_id=user_id))}
    ]
    return user

@router.post("/", response_model=UserCreate)
async def create_user(user: UserResponse, request: Request):
    existing_user = UserRepository.get_user_by_name(user.name)
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    
    created_user = UserRepository.create_user(user.model_dump(by_alias=True))
    token = create_access_token(created_user['id'])
    created_user['token'] = token
    created_user['links'] = [
        {"rel": "self", "href": str(request.url_for("get_user", user_id=created_user['id']))},
        {"rel": "garments", "href": str(request.url_for("get_user_garments", user_id=created_user['id']))}
    ]
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
