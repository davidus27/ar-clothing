from pymongo import MongoClient

# MongoDB connection string
# MONGO_URI = "mongodb://root:example@localhost:27017"
MONGO_URI = "mongodb://admin:adminpass@mongo:27017"
DB_NAME = "users_db"

# Create MongoDB client
client = MongoClient(MONGO_URI)
db = client[DB_NAME]