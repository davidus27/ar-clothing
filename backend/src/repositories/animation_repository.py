from ..core.database import db, grid_fs
from ..models.animations import Animation
from bson import ObjectId

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
    def create_animation(animation_data: Animation):
        result = db.animations.insert_one(animation_data.model_dump())
        animation_data.id = str(result.inserted_id)
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