from .schemas import ListRanking, Rank
from .model import RankingDAO

class RankingService:
    @staticmethod
    async def fetch_ranking() -> ListRanking:
        ranking_data = await RankingDAO.fetch_ranking()
        ranks = [Rank(**r) for r in ranking_data]
        return ListRanking(ranking=ranks)
