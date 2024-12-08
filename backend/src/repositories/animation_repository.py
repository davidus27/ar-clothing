from ..core.database import db, grid_fs
from ..models.animations_model import AnimationRequest
from .user_repository import UserRepository
from ..schemas.animation_schemas import AnimationPreview, AnimationDetail
from bson import ObjectId
from typing import List, Optional
from datetime import datetime

class AnimationRepository:

    @staticmethod
    async def save_file_to_gridfs(upload_file):
        # Save the file to GridFS asynchronously
        file_id = grid_fs.put(
            await upload_file.read(),
            filename=upload_file.filename,
            content_type=upload_file.content_type
        )
        return file_id

    @staticmethod
    def create_animation(animation_data: AnimationRequest):
        animation_data['created_at'] = datetime.datetime.now().strftime("%d/%m/%Y")

        result = db.animations.insert_one(animation_data.model_dump())
        animation_data["id"] = str(result.inserted_id)
        return animation_data

    @staticmethod
    def get_all_animations():
        animations = list(db.animations.find())
        for animation in animations:
            animation['id'] = str(animation['_id'])
            del animation['_id']
        return animations

    @staticmethod
    def get_animation_by_id(animation_id: str):
        animation = db.animations.find_one({"_id": ObjectId(animation_id)})
        if animation:
            animation['id'] = str(animation['_id'])
            del animation['_id']
        return animation

    @staticmethod
    async def get_animation_file(file_id: str):
        # Retrieve the file from GridFS
        grid_out = grid_fs.get(ObjectId(file_id))
        return grid_out
    

    @staticmethod
    def get_all_public_animations() -> List[AnimationPreview]:
        animations = list(db.animations.find({"isPublic": True}))
        previews = []
        for animation in animations:
            user = UserRepository.get_user_by_id(animation['author_id'])
            preview = AnimationPreview(
                id=str(animation['_id']),
                animationName=animation['animationName'],
                animationDescription=animation['animationDescription'],
                thumbnailFileId=animation.get('thumbnailFileId'),
                author={'id': user['id'], 'name': user['name'], 'imageBase64': user.get('imageBase64')}
            )
            previews.append(preview)
        return previews

    @staticmethod
    def get_animation_preview(animation_id: str) -> Optional[AnimationPreview]:
        animation = db.animations.find_one({"_id": ObjectId(animation_id), "isPublic": True})
        if animation:
            user = UserRepository.get_user_by_id(animation['author_id'])
            return AnimationPreview(
                id=str(animation['_id']),
                animationName=animation['animationName'],
                animationDescription=animation['animationDescription'],
                thumbnailFileId=animation.get('thumbnailFileId'),
                author={'id': user['id'], 'name': user['name'], 'imageBase64': user.get('imageBase64')}
            )
        return None

    @staticmethod
    def get_animation_detail(animation_id: str, requester_id: Optional[str] = None) -> Optional[AnimationDetail]:
        query = {"_id": ObjectId(animation_id)}
        animation = db.animations.find_one(query)
        if animation:
            if not animation['isPublic'] and animation['author_id'] != requester_id:
                return None
            user = UserRepository.get_user_by_id(animation['author_id'])
            return AnimationDetail(
                id=str(animation['_id']),
                animationName=animation['animationName'],
                animationDescription=animation['animationDescription'],
                isPublic=animation['isPublic'],
                physicalWidth=animation['physicalWidth'],
                physicalHeight=animation['physicalHeight'],
                animationFileId=animation.get('animationFileId'),
                thumbnailFileId=animation.get('thumbnailFileId'),
                author={
                    'id': user['id'],
                    'name': user['name'],
                    'imageBase64': user.get('imageBase64'),
                    'description': user.get('description')
                },
                created_at=animation['created_at']
            )
        return None

    @staticmethod
    def get_all_animations() -> List[AnimationDetail]:
        animations = list(db.animations.find())
        detailed = []
        for animation in animations:
            user = UserRepository.get_user_by_id(animation['author_id'])
            detail = AnimationDetail(
                id=str(animation['_id']),
                animationName=animation['animationName'],
                animationDescription=animation['animationDescription'],
                isPublic=animation['isPublic'],
                physicalWidth=animation['physicalWidth'],
                physicalHeight=animation['physicalHeight'],
                animationFileId=animation.get('animationFileId'),
                thumbnailFileId=animation.get('thumbnailFileId'),
                author={
                    'id': user['id'],
                    'name': user['name'],
                    'imageBase64': user.get('imageBase64'),
                    'description': user.get('description')
                },
                created_at=animation['created_at']
            )
            detailed.append(detail)
        return detailed

    @staticmethod
    async def get_animation_file(file_id: str):
        # Retrieve the file from GridFS
        grid_out = grid_fs.get(ObjectId(file_id))
        return grid_out