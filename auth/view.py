from fastapi import APIRouter, Depends, HTTPException, Response, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from auth.model import AuthDAO
from .schemas import UserRegister, UserLogin, TokenResponse, UserProfile
from .service import AuthService

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.post("/register", response_model=TokenResponse)
async def register(credentials: UserRegister):
    return await AuthService.register_user(credentials)


@router.post("/login", response_model=TokenResponse)
async def login(credentials: UserLogin):
    return await AuthService.login_user(credentials)


@router.get("/refresh")
async def refresh_token(): 
    ...
