from .utils import validate_password, hash_password
from .schemas import UserLogin, UserRegister
from typing import Optional, Dict, Any
from conn import get_db_connection
from asyncpg.exceptions import UniqueViolationError


class AuthDAO:
    @staticmethod
    async def check_user_credentials(credentials: UserLogin) -> bool:
        async with get_db_connection() as conn:
            row = await conn.fetchrow(
                """
                SELECT password_hash
                FROM users 
                WHERE username = $1
                """,
                credentials.username
            )
            
            if row is None:
                return {"success": False, "error": "Пользователь не существует"}
            
            if not validate_password(credentials.password, row['password_hash']):
                return {"success": False, "error": "Неверный пароль"}

            return {"success": True}


    @staticmethod
    async def register_user(credentials: UserRegister):
        try:
            password_hash = hash_password(credentials.password)

            async with get_db_connection() as conn:
                user_id = await conn.fetchval(
                    """
                    INSERT INTO users (username, password_hash, avatar)
                    VALUES ($1, $2, $3)
                    RETURNING id
                    """,
                    credentials.username, password_hash, credentials.avatar
                )
                return {"success": True, "user_id": user_id}
        except UniqueViolationError as e:
            if 'username' in e.constraint_name:
                return {"success": False, "error": "Username уже занят"}
            return {"success": False, "error": "Пользователь уже существует"}


    @staticmethod
    async def get_user_id_by_username(username: str) -> int:
        async with get_db_connection() as conn:
            user_id = await conn.fetchval(
                """
                SELECT id
                FROM users 
                WHERE username = $1
                """,
                username
            )
            return user_id


    @staticmethod
    async def get_user_by_id(user_id: int) -> Optional[Dict[str, Any]]:
        async with get_db_connection() as conn:
            row = await conn.fetchrow(
                """
                SELECT id, username, avatar
                FROM users 
                WHERE id = $1
                """,
                user_id
            )
            return dict(row) if row else None

    