from fastapi import FastAPI
from .api import users, animations, explore, library

app = FastAPI()

# Include routers
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(animations.router, prefix="/animations", tags=["Animations"])
app.include_router(explore.router, prefix="/explore", tags=["Explore page"])
app.include_router(library.router, prefix="/library", tags=["Library"])
