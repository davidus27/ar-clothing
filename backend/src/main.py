from fastapi import FastAPI
from .api import users

app = FastAPI()

# Include routers
app.include_router(users.router, prefix="/users", tags=["Users"])
# app.include_router(garments.router, prefix="/garments", tags=["Garments"])
# app.include_router(animations.router, prefix="/animations", tags=["Animations"])