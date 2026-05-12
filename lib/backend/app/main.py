import asyncio
from fastapi import FastAPI
from contextlib import asynccontextmanager
from fastapi.middleware.cors import CORSMiddleware
from routes.auth_routes import router as auth_router
from routes.gig_routes import router as gig_router
from routes.order_routes import router as order_router
from routes.admin_routes import router as admin_router
from routes.payment_routes import router as payment_router
from routes.search_routes import router as search_router
from routes.analytics_routes import router as analytics_router
from routes.media_routes import router as media_router
from Service.search_service import SearchService
from task_queue.AcceptanceQueue import process_order_acceptance_worker

search_service = SearchService()

@asynccontextmanager
async def lifespan(app: FastAPI):
    # --- STARTUP LOGIC ---
    await search_service.ensure_indexes()
    
    # Create the background worker task to run sequentially
    worker_task = asyncio.create_task(process_order_acceptance_worker())
    
    yield  # Server runs here
    
    # --- SHUTDOWN LOGIC ---
    # Properly cancel the background task upon server termination
    worker_task.cancel()
    try:
        await worker_task
    except asyncio.CancelledError:
        pass

app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "*",
    ],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(gig_router)
app.include_router(order_router)
app.include_router(admin_router)
app.include_router(payment_router)
app.include_router(search_router)
app.include_router(analytics_router)
app.include_router(media_router)

@app.get('/')
def greet():
    return "How are you my friend.Welcome back to FastApi"