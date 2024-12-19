import requests
import base64
import os
import random
from datetime import datetime
import json

# Base URL of the API
BASE_URL = "http://localhost:8000"  # Change to your actual API URL

# Folder containing images and thumbnails
IMAGES_FOLDER = "./images"
PROFILE_PICS = "./profile_pics"

# Mock data
USERS = [
    {"name": "David Drobny", "description": "AR enthusiast and tech geek"},
    {"name": "Anna Novak", "description": "Fashion designer and AR content creator"},
    {"name": "John Smith", "description": "Photographer with a passion for digital art"},
]

GARMENTS = [
    {"name": "AR Jacket", "uid": "JKT123"},
    {"name": "Smart T-Shirt", "uid": "TSH456"},
    {"name": "Interactive Cap", "uid": "CAP789"},
]

ANIMATIONS = [
    {"name": "Kitten Play", "description": "A playful kitten animation", "width": 10, "height": 10},
    {"name": "Galaxy Spin", "description": "A mesmerizing galaxy animation", "width": 10, "height": 20},
    {"name": "Burger", "description": "Best burger in town", "width": 7, "height": 7},
]

# Dictionary to store user tokens
USER_TOKENS = {}

# Helper function to read and encode an image file
def encode_image(file_path):
    with open(file_path, "rb") as img_file:
        return base64.b64encode(img_file.read()).decode("utf-8")

# Create users
def create_users():
    for user, image_file in zip(USERS, os.listdir(PROFILE_PICS)):
        image_path = os.path.join(PROFILE_PICS, image_file)

        user_payload = {
            "name": user["name"],
            "description": user["description"],
            "token": f"token_{user['name'].replace(' ', '_').lower()}",
            "imageBase64": encode_image(image_path),
        }

        response = requests.post(f"{BASE_URL}/users/", json=user_payload)
        if response.status_code == 200:
            body = response.json()
            USER_TOKENS[user["name"]] = body["token"]
            print(f"Created user: {user['name']}")
        else:
            print(f"Failed to create user: {user['name']} - {response.text}")

# Add garments to users
def add_garments():
    response = requests.get(f"{BASE_URL}/users/")
    if response.status_code == 200:
        users = response.json()
        for user in users:
            for garment in GARMENTS:
                garment_payload = {
                    "name": garment["name"],
                    "uid": garment["uid"],
                    "user_id": user["id"],
                    "animation_id": random.choice(ANIMATIONS)["name"]
                }

                headers = {
                    "Authorization": f"Bearer {USER_TOKENS[user['name']]}"
                }
                user_id = user["id"]
                garment_response = requests.post(f"{BASE_URL}/users/{user_id}/garments", json=garment_payload, headers=headers)
                if garment_response.status_code == 200:
                    print(f"Added garment {garment['name']} to user {user['name']}")
                else:
                    print(f"Failed to add garment to user {user['name']} - {garment_response.text}")
    else:
        print(f"Failed to fetch users: {response.text}")

# Create animations
def create_animations():
    for animation, image_name in zip(ANIMATIONS, os.listdir(IMAGES_FOLDER)):
        thumbnail_path = os.path.join(IMAGES_FOLDER, image_name)
        animation_path = os.path.join(IMAGES_FOLDER, image_name)

        animation_payload = {
            "animation_name": animation["name"],
            "animation_description": animation["description"],
            "is_public": random.choice([True, False]),
            "physical_width": animation["width"],
            "physical_height": animation["height"],
        }

        files = {
            "thumbnail": open(thumbnail_path, "rb"),
            "file": open(animation_path, "rb"),
        }

        # Use a random user's token for creating animations
        user_name = random.choice(list(USER_TOKENS.keys()))
        headers = {
            "Authorization": f"Bearer {USER_TOKENS[user_name]}"
        }

        response = requests.post(f"{BASE_URL}/animations/", data=animation_payload, files=files, headers=headers)
        if response.status_code == 200:
            print(f"Created animation: {animation['name']}")
        else:
            print(f"Failed to create animation: {animation['name']} - {response.text}")

# Main function
if __name__ == "__main__":
    print("Starting database population...")
    create_users()
    add_garments()
    create_animations()
    print("Database population complete.")