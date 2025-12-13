from conn import get_db_connection
from auth.utils import hash_password, validate_password
from asyncpg.exceptions import UniqueViolationError
from .schemas import AccountProfile, ChangePassword, ChangeUsername

class AccountDAO:
    @staticmethod
    async def get_profile(user_id: int) -> AccountProfile:
        async with get_db_connection() as conn:
            user_row = await conn.fetchrow("SELECT username FROM Users WHERE id=$1", user_id)
            if not user_row:
                return None
            
            username = user_row['username']

            # Stats
            rows = await conn.fetch("SELECT result, count(*) as cnt FROM Games WHERE user_id=$1 GROUP BY result", user_id)
            stats = {"win": 0, "lose": 0, "draw": 0}
            for r in rows:
                stats[r['result']] = r['cnt']
            
            wins = stats['win']
            losses = stats['lose']
            draws = stats['draw']
            total = wins + losses + draws
            winrate = (wins / total * 100) if total > 0 else 0.0

            ranking_row = await conn.fetchrow("SELECT best_win_time FROM Rankings WHERE user_id=$1", user_id)
            best_win_time = ranking_row['best_win_time'] if ranking_row else None

            return AccountProfile(
                username=username,
                wins=wins,
                losses=losses,
                draws=draws,
                winrate=round(winrate, 2),
                best_win_time=best_win_time
            )

    @staticmethod
    async def change_password(user_id: int, data: ChangePassword) -> dict:
        async with get_db_connection() as conn:
            # Check old password
            row = await conn.fetchrow("SELECT password_hash FROM Users WHERE id=$1", user_id)
            if not row:
                 return {"success": False, "error": "Пользователь не найден"}
            
            if not validate_password(data.old_password, row['password_hash']):
                return {"success": False, "error": "Неверный старый пароль"}
            
            new_hash = hash_password(data.new_password)
            await conn.execute("UPDATE Users SET password_hash=$1 WHERE id=$2", new_hash, user_id)
            return {"success": True}

    @staticmethod
    async def change_username(user_id: int, data: ChangeUsername) -> dict:
        async with get_db_connection() as conn:
            try:
                await conn.execute("UPDATE Users SET username=$1 WHERE id=$2", data.new_username, user_id)
                return {"success": True}
            except UniqueViolationError:
                 return {"success": False, "error": "Username уже занят"}
