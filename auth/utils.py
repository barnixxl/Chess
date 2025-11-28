import bcrypt
from datetime import datetime, timedelta, timezone
from functools import lru_cache
from typing import Any
import jwt
from jwt.exceptions import InvalidTokenError

from config import settings


@lru_cache(maxsize=1)
def get_private_key() -> str:
    return settings.auth_jwt.get_private_key()


@lru_cache(maxsize=1)
def get_public_key() -> str:
    return settings.auth_jwt.get_public_key()


def hash_password(password: str) -> str:
    salt = bcrypt.gensalt()
    pwd_bytes: bytes = password.encode()
    hashed = bcrypt.hashpw(pwd_bytes, salt)
    return hashed.decode('utf-8')


def validate_password(
    password: str,
    hashed_password: str,
) -> bool:
    return bcrypt.checkpw(
        password=password.encode(),
        hashed_password=hashed_password.encode(),
    )


def encode_jwt(
    payload: dict[str, Any],
    private_key: str | None = None,
    algorithm: str | None = None,
    expire_minutes: int | None = None,
    expire_timedelta: timedelta | None = None,
) -> str:
    to_encode = payload.copy()
    now = datetime.now(timezone.utc)
    
    if expire_timedelta:
        expire = now + expire_timedelta
    else:
        minutes = expire_minutes or settings.auth_jwt.access_token_expire_minutes
        expire = now + timedelta(minutes=minutes)
    
    to_encode.update(
        exp=expire,
        iat=now,
    )
    
    key = private_key or get_private_key()
    algo = algorithm or settings.auth_jwt.algorithm
    
    encoded = jwt.encode(
        to_encode,
        key,
        algorithm=algo,
    )
    return encoded


def decode_jwt(
    token: str | bytes,
    public_key: str | None = None,
    algorithm: str | None = None,
) -> dict[str, Any]:
    key = public_key or get_public_key()
    algo = algorithm or settings.auth_jwt.algorithm
    
    decoded = jwt.decode(
        token,
        key,
        algorithms=[algo],
    )
    return decoded

