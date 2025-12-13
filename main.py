import uvicorn
from fastapi import FastAPI
from starlette.responses import RedirectResponse
from account import router as account_router
from auth import router as auth_router
from game import router as game_router
from ranking import router as ranking_router
from conn import init_db 
from contextlib import asynccontextmanager
from fastapi.middleware.cors import CORSMiddleware
from config import settings

@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    yield

app = FastAPI(
    title="McbChess API",
    description="API for McbChess application",
    version="1.0.0",
    lifespan=lifespan
)

app.include_router(auth_router)
app.include_router(game_router)
app.include_router(ranking_router)
app.include_router(account_router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def redirect_to_docs():
    return RedirectResponse(url="/docs")


@app.get("/health")
async def health_check():
    return {"status": "ok"}


if __name__ == "__main__":
    uvicorn.run("main:app", host=settings.APP_HOST, port=settings.APP_PORT, reload=True)
