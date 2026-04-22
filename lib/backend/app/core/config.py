import os
from dotenv import load_dotenv
load_dotenv()
class config:
    DATABASE_URL=os.getenv("MONGO_URL")
    DATABASE_NAME=os.getenv("DB_NAME")
    SECRET_KEY=os.getenv("SECRET_KEY")
    ALGORITHM=os.getenv("ALGORITHM")    
    ACCESS_TOKEN_EXPIRE_MINUTES=os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES")
    

settings = config()