import requests

def create_mock_users():
    users = [
        {"name": "Alice", "email": "alice@example.com"},
        {"name": "Bob", "email": "bob@example.com"},
        {"name": "Charlie", "email": "charlie@example.com"}
    ]
    
    for user in users:
        response = requests.post("http://localhost:80/users/", json=user)
        if response.status_code == 200:
            print(f"User {user['name']} added successfully.")
        else:
            print(f"Failed to add {user['name']}.")

if __name__ == "__main__":
    create_mock_users()
