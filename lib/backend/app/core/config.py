import os
from dotenv import load_dotenv
load_dotenv()
class config:
    DATABASE_URL=os.getenv("MONGO_URL") or "mongodb://localhost:27017"
    DATABASE_NAME=os.getenv("DB_NAME") or "nearme_db"
    SECRET_KEY=os.getenv("SECRET_KEY") or "fallback_secret_key_change_me_in_prod"
    ALGORITHM=os.getenv("ALGORITHM") or "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES=os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES") or "30"
    STRIPE_SECRET_KEY=os.getenv("STRIPE_SECRET_KEY")
    STRIPE_WEBHOOK_SECRET=os.getenv("STRIPE_WEBHOOK_SECRET")
    CLOUDINARY_CLOUD_NAME=os.getenv("CLOUDINARY_CLOUD_NAME")
    CLOUDINARY_API_KEY=os.getenv("CLOUDINARY_API_KEY")
    CLOUDINARY_API_SECRET=os.getenv("CLOUDINARY_API_SECRET")
    

settings = config()