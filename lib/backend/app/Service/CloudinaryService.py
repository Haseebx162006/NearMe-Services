from fastapi import HTTPException
from core.config import settings
import cloudinary
import cloudinary.uploader


class CloudinaryService:
    def __init__(self):
        # Configure Cloudinary once (safe to call multiple times)
        if not settings.CLOUDINARY_CLOUD_NAME or not settings.CLOUDINARY_API_KEY or not settings.CLOUDINARY_API_SECRET:
            # Keep message beginner-friendly
            raise HTTPException(
                status_code=500,
                detail="Cloudinary is not configured. Please set CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET in .env",
            )

        cloudinary.config(
            cloud_name=settings.CLOUDINARY_CLOUD_NAME,
            api_key=settings.CLOUDINARY_API_KEY,
            api_secret=settings.CLOUDINARY_API_SECRET,
            secure=True,
        )

    async def upload_file(self, file_bytes: bytes, filename: str, folder: str = "nearme"):
        """
        Uploads raw bytes to Cloudinary and returns the secure URL.
        Beginner-friendly: minimal parameters, clear response.
        """
        try:
            result = cloudinary.uploader.upload(
                file_bytes,
                folder=folder,
                public_id=None,
                resource_type="auto",  # handles image/video/other
                use_filename=True,
                unique_filename=True,
            )
            return {
                "url": result.get("secure_url") or result.get("url"),
                "public_id": result.get("public_id"),
                "resource_type": result.get("resource_type"),
                "bytes": result.get("bytes"),
                "format": result.get("format"),
                "original_filename": filename,
            }
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Cloudinary upload failed: {str(e)}")

