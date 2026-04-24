from fastapi import FastAPI
from routes.auth_routes import router as auth_router
from routes.gig_routes import router as gig_router
from routes.order_routes import router as order_router

app = FastAPI()

app.include_router(auth_router)
app.include_router(gig_router)
app.include_router(order_router)


@app.get('/')
def greet():
    return "How are you my friend.Welcome back to FastApi"