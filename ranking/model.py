

from conn import get_db_connection


class RankingDAO:
    @staticmethod
    async def fetch_ranking() -> dict[str, any]:
            async with get_db_connection() as conn:
                rows = await conn.fetch("SELECT username, rating FROM Rankings JOIN Users ON Rankings.user_id = Users.id ORDER BY rating DESC")
                return [{"username": r["username"], "rating": r["rating"]}  for r in rows]