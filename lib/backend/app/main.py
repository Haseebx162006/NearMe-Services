from fastapi import FastAPI
from routes.auth_routes import router as auth_router
from routes.gig_routes import router as gig_router
from routes.order_routes import router as order_router
from routes.admin_routes import router as admin_router
from routes.payment_routes import router as payment_router
from routes.search_routes import router as search_router
from Service.search_service import SearchService

app = FastAPI()
search_service = SearchService()


@app.on_event("startup")
async def startup_search_indexes():
    await search_service.ensure_indexes()

app.include_router(auth_router)
app.include_router(gig_router)
app.include_router(order_router)
app.include_router(admin_router)
app.include_router(payment_router)
app.include_router(search_router)


@app.get('/')
def greet():
    return "How are you my friend.Welcome back to FastApi"