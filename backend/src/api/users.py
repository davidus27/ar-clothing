from fastapi import APIRouter, HTTPException
from ..models.user import UserCreate, UserResponse, UserUpdate
from ..repositories.user_repository import UserRepository

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

@router.post("/", response_model=UserResponse)
async def create_user(user: UserCreate):
    user_data = user.model_dump(by_alias=True)
    return UserRepository.create_user(user_data)


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
