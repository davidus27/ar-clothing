from ..core.database import db
from bson import ObjectId

class LibraryRepository:

    @staticmethod
    def get_library_by_user_id(user_id: str):
        library = db.libraries.find_one({"user_id": user_id})
        if library:
            library['id'] = str(library['_id'])
            del library['_id']
        return library

    @staticmethod
    def add_animation_to_library(user_id: str, animation_id: str):
        result = db.libraries.update_one(
            {"user_id": user_id},
            {"$addToSet": {"animation_ids": animation_id}},
            upsert=True
        )
        return result.matched_count > 0

    @staticmethod
    def get_animations_by_user_id(user_id: str):
        library = db.libraries.find_one({"user_id": user_id})
        if library:
            return library.get("animation_ids", [])
        return []