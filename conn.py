from contextlib import asynccontextmanager
import asyncpg
from config import settings

async def init_db():
    async with get_db_connection() as conn:
        await conn.execute("""
            CREATE TABLE IF NOT EXISTS Users (
                id SERIAL PRIMARY KEY,
                username VARCHAR(25) UNIQUE,
                password_hash TEXT NOT NULL,
                avatar TEXT
            );
        """)

@asynccontextmanager
async def get_db_connection():
    conn: asyncpg.Connection = await asyncpg.connect(
        database=settings.POSTGRES_DB,
        user=settings.POSTGRES_USER, 
        password=settings.POSTGRES_PASSWORD, 
        host=settings.POSTGRES_HOST, 
        port=settings.POSTGRES_PORT
    )
    try:
        async with conn.transaction():
            yield conn
    finally:
        await conn.close()