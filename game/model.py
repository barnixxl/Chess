from typing import Dict
from .schemas import GameResult
from conn import get_db_connection


class GameDAO:
    @staticmethod
    async def save_game(user_id: int, result: GameResult, win_time: int) -> None: 
        async with get_db_connection() as conn:
            await conn.execute("""
                INSERT INTO Games (user_id, result, win_time)
                VALUES ($1, $2, $3)
            """, user_id, result.value, win_time)

    
    @staticmethod
    async def fetch_current_ranking(user_id: int) -> dict[str, any]:
        async with get_db_connection() as conn:
            ranking = await conn.fetchrow("SELECT rating, best_win_time FROM Rankings WHERE user_id=$1", user_id)
            if not ranking:
                await conn.execute("INSERT INTO Rankings (user_id) VALUES ($1)", user_id)
                ranking = await conn.fetchrow("SELECT rating, best_win_time FROM Rankings WHERE user_id=$1", user_id)
            return ranking

    @staticmethod
    async def fetch_recent_games(user_id: int) -> Dict[str, any]:
        async with get_db_connection() as conn:
            return await conn.fetch("SELECT result FROM Games WHERE user_id=$1 ORDER BY dt DESC LIMIT 6", user_id)
        
    @staticmethod
    async def update_rating(new_rating: int, best_win_time: int, user_id: int) -> None:
        async with get_db_connection() as conn:
            await conn.execute("""
                UPDATE Rankings SET rating=$1, best_win_time=$2 WHERE user_id=$3
            """, new_rating, best_win_time, user_id)
