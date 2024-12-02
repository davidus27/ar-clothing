# AR backend
This is backend responsible for business logic. It handles external AR assets operations, relational database, authorization and authentication


To start the app on development:
```sh
fastapi dev main.py
```
## Project structure
```
project_root/
│
├── src/
│   ├── __init__.py
│   ├── main.py                 # Entry point of the FastAPI app
│   ├── api/                    # API routes layer
│   │   ├── __init__.py
│   │   ├── users.py            # Endpoints for user-related routes
│   │   ├── garments.py         # Endpoints for garment-related routes
│   │   ├── animations.py       # Endpoints for animation-related routes
│   │
│   ├── core/                   # Core configurations and utilities
│   │   ├── __init__.py
│   │   ├── config.py           # Configuration settings (e.g., DB, environment)
│   │   ├── database.py         # Database connection setup
│   │   ├── logger.py           # Logging utilities
│   │
│   ├── services/               # Business logic layer
│   │   ├── __init__.py
│   │   ├── user_service.py     # Service logic for user-related operations
│   │   ├── garment_service.py  # Service logic for garment operations
│   │   ├── animation_service.py# Service logic for animations
│   │
│   ├── models/                 # Database models
│   │   ├── __init__.py
│   │   ├── user.py             # User model
│   │   ├── garment.py          # Garment model
│   │   ├── animation.py        # Animation model
│   │
│   ├── schemas/                # DTOs - Pydantic models for request/response
│   │   ├── __init__.py
│   │   ├── user_schemas.py     # Schemas for user-related requests/responses
│   │   ├── garment_schemas.py  # Schemas for garment-related requests/responses
│   │   ├── animation_schemas.py# Schemas for animation-related requests/responses
│   │
│   ├── repositories/           # DAO - Database access
│   │   ├── __init__.py
│   │   ├── user_repository.py  # Database queries for users
│   │   ├── garment_repository.py # Database queries for garments
│   │   ├── animation_repository.py # Database queries for animations
│
├── animations/                 # Static files or animation assets
│   ├── ...
│
├── requirements.txt            # Python dependencies
├── README.md                   # Project documentation
└── .env                        # Environment variables
```

### Progress
- we started by pulling mongodb:
```sh
docker pull mongo:latest
```

then running:

```sh
docker run --name fastapi-mongo -d -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=adminpass mongo:latest
```
