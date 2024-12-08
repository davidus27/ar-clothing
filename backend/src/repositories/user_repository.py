from ..core.database import db
from ..models.garments import Garment, GarmentCreate
import datetime
from bson import ObjectId


class UserRepository:

    @staticmethod
    def get_all_users():
        # this is not the ideal way to do this, but it works for now
        # maybe use _id instead of id and ignore it when returning the data
        users = list(db.users.find())
        for user in users:
            user['id'] = str(user['_id'])
            del user['_id']
        return users
 
    # src/repositories/user_repository.py
    @staticmethod
    def get_user_by_id(user_id: str):
        from bson import ObjectId
        user = db.users.find_one({"_id": ObjectId(user_id)})
        if user:
            user['id'] = str(user['_id'])
            del user['_id']
        return user
    
    @staticmethod
    def get_user_by_name(name: str):
        user = db.users.find_one({"name": name})
        if user:
            user['id'] = str(user['_id'])
            del user['_id']
        return user
    
    @staticmethod
    def create_user(user_data: dict):
        # add today date
        user_data['joinedDate'] = datetime.datetime.now().strftime("%d/%m/%Y")
        result = db.users.insert_one(user_data)
        
        user_data['id'] = str(result.inserted_id)
        return user_data
    
    @staticmethod
    def update_user(user_id: str, update_data: dict):
        result = db.users.update_one({"id": user_id}, {"$set": update_data})
        return result.matched_count > 0
    
    @staticmethod
    def delete_user(user_id: str):
        result = db.users.delete_one({"id": user_id})
        return result.deleted_count > 0

    @staticmethod
    def delete_all_users():
        result = db.users.delete_many({})
        return result.deleted_count
    
    @staticmethod
    def add_garment_to_user(user_id: str, garment: GarmentCreate):
        user = UserRepository.get_user_by_id(user_id)
        if not user:
            return None
        new_garment = Garment(**garment.model_dump())

        # Add the new garment to the user's garments array in the database
        result = db.users.update_one(
            {"_id": ObjectId(user_id)},
            {"$push": {"garments": new_garment.model_dump()}}
        )

        if result.modified_count == 0:
            return None

        return new_garment
    
    @staticmethod
    def update_user(user_id: str, update_data: dict):
        result = db.users.update_one(
            {"_id": ObjectId(user_id)},
            {"$set": update_data}
        )
        return result.matched_count > 0

    @staticmethod
    def delete_user(user_id: str):
        result = db.users.delete_one({"_id": ObjectId(user_id)})
        return result.deleted_count > 0