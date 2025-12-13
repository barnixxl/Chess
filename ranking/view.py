from fastapi import APIRouter

from ranking.schemas import ListRanking
from .service import RankingService

router = APIRouter(prefix="/ranking", tags=["ranking"])

@router.get(path="/", response_model=ListRanking)
async def get_ranking():
    return await RankingService.fetch_ranking()