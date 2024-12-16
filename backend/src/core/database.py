from pymongo import MongoClient
from gridfs import GridFS

# MongoDB connection string
MONGO_URI = "mongodb://admin:adminpass@localhost:27017"
DB_NAME = "users_db"

# Create MongoDB client
client = MongoClient(MONGO_URI)
db = client[DB_NAME]

# Initialize GridFS
grid_fs = GridFS(db)