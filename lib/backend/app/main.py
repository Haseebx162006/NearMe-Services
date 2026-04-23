from fastapi import FastAPI
from routes.auth_routes import router as auth_router

app = FastAPI()

app.include_router(auth_router)


@app.get('/')
def greet():
    return "How are you my friend.Welcome back to FastApi"