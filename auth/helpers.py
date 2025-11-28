from datetime import timedelta
from typing import Any
from .utils import encode_jwt, decode_jwt
from jwt import InvalidTokenError


TOKEN_TYPE_FIELD = "type"
ACCESS_TOKEN_TYPE = "access"
REFRESH_TOKEN_TYPE = "refresh"


def create_access_token(
    user_id: int,
    **extra_data: Any
) -> str:
    payload = {
        "sub": str(user_id),
        "type": "access",
        **extra_data
    }
    return encode_jwt(payload)


def create_refresh_token(
    user_id: int,
    expire_days: int = 30,
) -> str:
    payload = {
        "sub": str(user_id),
        "type": "refresh",
    }
    return encode_jwt(
        payload,
        expire_timedelta=timedelta(days=expire_days)
    )


def verify_token(token: str | bytes) -> dict[str, Any] | None:
    try:
        return decode_jwt(token)
    except InvalidTokenError:
        return None