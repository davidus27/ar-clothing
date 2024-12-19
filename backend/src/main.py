from fastapi import FastAPI
from .api import users, animations, explore, library, garment

app = FastAPI()

# Simple health check for client
@app.get("/health")
async def health_check():
    return {"status": "ok"}

# Include routers
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(garment.router, prefix="/garment", tags=["Garment"])
app.include_router(animations.router, prefix="/animations", tags=["Animations"])
app.include_router(explore.router, prefix="/explore", tags=["Explore page"])
app.include_router(library.router, prefix="/library", tags=["Library"])
