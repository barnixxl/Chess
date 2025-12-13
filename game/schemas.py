from enum import Enum
from pydantic import BaseModel

class GameResult(str, Enum):
    WIN = "win"
    LOSE = "lose"
    DRAW = "draw"


class GameRequest(BaseModel):
    result: GameResult  # win, lose, draw
    win_time: int | None = None


class GameResponse(BaseModel):
    rating: int
    rating_change: int
    best_win_time: int | None


