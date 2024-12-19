from ..core.database import db
from ..models.garments_model import Garment, GarmentCreate
from bson import ObjectId

class GarmentRepository:

    @staticmethod
    def create_garment(garment_data: GarmentCreate):
        result = db.garments.insert_one(garment_data.model_dump())
        garment_data.id = str(result.inserted_id)
        return garment_data

    @staticmethod
    def get_garment_by_id(garment_id: str):
        garment = db.garments.find_one({"_id": ObjectId(garment_id)})
        if garment:
            garment['id'] = str(garment['_id'])
            del garment['_id']
        return garment

    @staticmethod
    def get_garments_by_user_id(user_id: str):
        garments = list(db.garments.find({"user_id": user_id}))
        for garment in garments:
            garment['id'] = str(garment['_id'])
            del garment['_id']
        return garments

    @staticmethod
    def update_garment(garment_id: str, update_data: dict):
        result = db.garments.update_one(
            {"_id": ObjectId(garment_id)},
            {"$set": update_data}
        )
        return result.matched_count > 0

    @staticmethod
    def delete_garment(garment_id: str):
        result = db.garments.delete_one({"_id": ObjectId(garment_id)})
        return result.deleted_count > 0

    @staticmethod
    def delete_all_garments():
        result = db.garments.delete_many({})
        return result.deleted_count