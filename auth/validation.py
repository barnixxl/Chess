from fastapi import Depends, HTTPException, status, WebSocket, WebSocketDisconnect
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jwt import InvalidTokenError

from .exception import unauthorized_ex
from .service import AuthService
from .schemas import UserProfile

from .helpers import *
from .utils import decode_jwt

security = HTTPBearer()


def get_current_token_payload(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> dict:
    try:
        payload = decode_jwt(
            token=credentials.credentials,
        )
    except InvalidTokenError:
        raise unauthorized_ex
    return payload


def validate_token_type(
    payload: dict,
    token_type: str,
) -> None:
    current_token_type = payload.get(TOKEN_TYPE_FIELD)
    if current_token_type != token_type:
        raise unauthorized_ex


class UserGetterFromToken:
    def __init__(self, token_type: str):
        self.token_type = token_type

    async def __call__(
        self,
        payload: dict = Depends(get_current_token_payload),
    ) -> UserProfile:
        validate_token_type(payload, self.token_type)
        return payload


get_current_auth_user = UserGetterFromToken(ACCESS_TOKEN_TYPE)
get_current_refresh_user = UserGetterFromToken(REFRESH_TOKEN_TYPE)
