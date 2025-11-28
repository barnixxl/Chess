from pydantic import BaseModel
from typing import Optional


class UserProfile(BaseModel):
    id: int
    username: str
    avatar: Optional[str] = None


class UserRegister(BaseModel):
    username: str
    password: str
    avatar: Optional[str] = None


class UserLogin(BaseModel):
    username: str
    password: str


class TokenResponse(BaseModel):
    success: bool
    token: str

