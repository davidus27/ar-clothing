import requests
import json

def send_data():
    url = "http://127.0.0.1:8000/animations"
    animation_data = {
        "animation_name": "Sample Animation",
        "animation_description": "This is a sample animation.",
        "is_public": True,
        "physical_width": 10,
        "physical_height": 10
    }
    files = {
        "file": open("/Users/daviddrobny/Downloads/giraffe.gif", "rb"),
    }
    headers = {
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2NzU1Yzk5NDAzODVkNjQxZjMzNDYzOGYiLCJpYXQiOjE3MzM2NzU0MTJ9.az7hekF17QU89OTMtDYHs1N-RuIUBOOXzE_2_v6RJgM"
    }

    response = requests.post(url, data=animation_data, files=files, headers=headers)
    print(response.status_code)

if __name__ == "__main__":
    for i in range(100):
        send_data()