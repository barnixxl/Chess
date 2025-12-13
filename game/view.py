from fastapi import APIRouter, Depends
from auth.validation import get_current_auth_user
from .service import GameService
from .schemas import GameRequest, GameResponse
router = APIRouter(prefix="/game", tags=["game"])


@router.post(path="/", response_model=GameResponse)
async def save_game(game: GameRequest, payload: dict = Depends(get_current_auth_user)):
    return await GameService.save_game(game, payload)