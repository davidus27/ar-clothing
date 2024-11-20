import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
from fastapi.responses import FileResponse
from fastapi import Request


# Initialize FastAPI app
app = FastAPI()

# Path to the local folder containing animations and assets
ASSETS_FOLDER = "animations/"  # Local path where your animations/assets are stored


class Animation(BaseModel):
    id: str
    name: str
    uid: str
    url: str  # URL to access the animation or asset


class AnimationListResponse(BaseModel):
    animations: List[Animation]


@app.get("/animations/{animation_id}", response_model=Animation)
async def get_animation(animation_id: str):
    """
    Endpoint to retrieve a specific animation or asset by ID from the local folder.
    """
    try:
        # Construct the path to the animation file (can be any type)
        animation_file_path = os.path.join(ASSETS_FOLDER, animation_id)
        
        # Check if the file exists
        if not os.path.exists(animation_file_path):
            raise HTTPException(status_code=404, detail="Animation not found")
        
        # Create the URL to access the file locally
        # This URL will be used to access the file via the /animations/{animation_id}/file endpoint
        url = f"/animations/{animation_id}/file"
        
        # Return metadata with URL to the asset
        animation = Animation(
            id=animation_id,
            name=f"Asset {animation_id}",
            uid=f"UID-{animation_id}",
            url=url
        )
        
        return animation

    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to retrieve animation")


@app.get("/animations/{animation_id}/file")
async def get_animation_file(animation_id: str):
    """
    Endpoint to serve the actual animation or asset file from the local folder.
    This supports any file type in the 'animations/' folder.
    """
    try:
        # Construct the path to the asset file (can be any type)
        animation_file_path = os.path.join(ASSETS_FOLDER, animation_id)
        
        # Check if the file exists
        if not os.path.exists(animation_file_path):
            raise HTTPException(status_code=404, detail="Animation not found")
        
        # Return the asset file as a response
        return FileResponse(animation_file_path)

    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to serve asset file")


@app.get("/animations", response_model=AnimationListResponse)
async def list_animations():
    """
    Endpoint to retrieve all asset names and UIDs from the local folder.
    This will list any files inside the 'animations/' folder.
    """
    try:
        # List all files in the 'animations' folder
        asset_files = [f for f in os.listdir(ASSETS_FOLDER) if os.path.isfile(os.path.join(ASSETS_FOLDER, f))]
        
        animations = []
        
        for asset_file in asset_files:
            # Create an ID based on the filename (you could use a more complex system if needed)
            animation_id = asset_file
            
            # Create the URL to access the asset file
            url = f"/animations/{animation_id}/file"
            
            animations.append(Animation(
                id=animation_id,
                name=f"Asset {animation_id}",
                uid=f"UID-{animation_id}",
                url=url
            ))
        
        return AnimationListResponse(animations=animations)

    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to retrieve animations")


# To run the app, use the following command in the terminal:
# uvicorn main:app --reload
