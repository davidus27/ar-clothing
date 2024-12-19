#!/usr/bin/env python3
import os
import requests
from dotenv import load_dotenv
import subprocess
from datetime import datetime

def read_env():
    """Load environment variables from .env file."""
    load_dotenv()
    cookies = os.getenv("OVERLEAF_COOKIES")
    output_dir = os.getenv("OUTPUT_DIR", "backups")
    return cookies, output_dir

def download_zip(cookies, url="http://localhost/project/675f0ee65728440b49c46fdd/download/zip"):
    """Download the project .zip file from Overleaf server."""
    headers = {
        "Cookie": cookies,
        "Accept": "application/zip",
        "User-Agent": "Mozilla/5.0"
    }

    response = requests.get(url, headers=headers, stream=True)
    if response.status_code == 200:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"project_backup_{timestamp}.zip"
        with open(filename, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        return filename
    else:
        raise Exception(f"Failed to download file: {response.status_code} {response.reason}")

def save_to_git(filename, output_dir):
    """Save the downloaded file to a Git repository."""
    # Ensure the output directory exists
    os.makedirs(output_dir, exist_ok=True)

    # Move the file to the output directory
    dest_path = os.path.join(output_dir, filename)
    os.rename(filename, dest_path)

    # Add, commit, and manage history
    # subprocess.run(["git", "add", "."], cwd=output_dir)
    # subprocess.run(["git", "commit", "-m", f"Thesis backup on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"], cwd=output_dir)

if __name__ == "__main__":
    try:
        # Load environment variables
        cookies, output_dir = read_env()

        # Step 1: Download the .zip file
        print("Downloading project zip file...")
        zip_file = download_zip(cookies)
        print(f"Downloaded: {zip_file}")

        # Step 2: Save it to Git repository
        print("Saving to Git...")
        save_to_git(zip_file, output_dir)
        print("Backup completed successfully.")
    except Exception as e:
        print(f"Error: {e}")

