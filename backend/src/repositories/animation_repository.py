from ..core.database import db, grid_fs
from ..models.animations_model import AnimationRequest
from .user_repository import UserRepository
# from ..schemas.animation_schemas import AnimationPreview, AnimationDetail
from bson import ObjectId
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
        animation_data['created_at'] = datetime.now().strftime("%d/%m/%Y")

        result = db.animations.insert_one(animation_data)
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
    async def get_animation_file(file_id: str):
        # Retrieve the file from GridFS
        grid_out = grid_fs.get(ObjectId(file_id))
        return grid_out