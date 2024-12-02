from ..core.database import db

class UserRepository:
    @staticmethod
    def get_all_users():
        return list(db.users.find({}, {"_id": 0}))

    @staticmethod
    def get_user_by_id(user_id: str):
        return db.users.find_one({"id": user_id}, {"_id": 0})
    
    @staticmethod
    def create_user(user_data: dict):
        db.users.insert_one(user_data)
        return user_data
    
    @staticmethod
    def update_user(user_id: str, update_data: dict):
        result = db.users.update_one({"id": user_id}, {"$set": update_data})
        return result.matched_count > 0
    
    @staticmethod
    def delete_user(user_id: str):
        result = db.users.delete_one({"id": user_id})
        return result.deleted_count > 0
