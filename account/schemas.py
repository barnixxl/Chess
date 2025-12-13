from pydantic import BaseModel, Field

class AccountProfile(BaseModel):
    username: str
    wins: int
    losses: int
    draws: int
    winrate: float
    best_win_time: int | None = None

class ChangePassword(BaseModel):
    old_password: str
    new_password: str = Field(..., min_length=4) 

class ChangeUsername(BaseModel):
    new_username: str = Field(..., min_length=3)
