from fastapi import APIRouter, Depends, UploadFile, File, Query
from core.checker import role_checker
from Service.CloudinaryService import CloudinaryService

router = APIRouter(prefix="/media", tags=["Media"])


@router.post("/upload")
async def upload_media(
    file: UploadFile = File(...),
    folder: str = Query("nearme", description="Cloudinary folder name"),
    current_user: dict = Depends(role_checker(["customer", "freelancer", "admin"])),
):
    """
    Uploads any file to Cloudinary and returns the hosted URL.

    Why this exists:
    - Flutter uploads file -> backend -> Cloudinary
    - Backend returns secure URL, which you store in MongoDB (profile_picture, gig images, etc.)
    """
    content = await file.read()
    service = CloudinaryService()
    return await service.upload_file(content, filename=file.filename or "upload", folder=folder)

