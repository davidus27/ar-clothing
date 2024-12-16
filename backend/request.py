import requests
import json
import base64

def get_file_base64():
    with open("/Users/daviddrobny/Downloads/giraffe.gif", "rb") as file:
        value = base64.b64encode(file.read())
        print(value)
        return value

token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2NzVlZmVlZjkxYThkYjM2N2VhYjhiMzciLCJpYXQiOjE3MzQyNzg4OTV9._8XbFmoMUiEVebnqzOMJJXMHp7TROHcAa0vw17ZjPnE"

def send_data():
    url = "http://127.0.0.1:8000/animations"
    animation_data = {
        "animation_name": "The ultimate burger",
        "animation_description": "This is a my burger animation.",
        "is_public": True,
        "physical_width": 10,
        "physical_height": 10,
        # "thumbnail": get_file_base64(),
    }
    files = {
        "thumbnail": open("/Users/daviddrobny/Downloads/burger.jpg", "rb"),
        "file": open("/Users/daviddrobny/Downloads/burger.jpg", "rb"),
    }
    headers = {
        "Authorization": f"Bearer {token}"
    }

    response = requests.post(url, data=animation_data, files=files, headers=headers)
    print(response.status_code)
    print(response.json())

if __name__ == "__main__":
    send_data()