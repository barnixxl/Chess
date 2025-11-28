from .schemas import UserRegister, UserLogin, TokenResponse, UserProfile
from .model import AuthDAO
from .helpers import create_access_token, create_refresh_token, verify_token
from typing import Optional
from .exception import unauthorized_ex


class AuthService:
    @staticmethod
    async def register_user(user_data: UserRegister) -> TokenResponse:

        result = await AuthDAO.register_user(user_data)
        
        if not result["success"]:
            raise unauthorized_ex
        
        user_id = result["user_id"]
        access_token = create_access_token(user_id)
        refresh_token = create_refresh_token(user_id)
        
        # TODO: Сохранение refresh token в базу данных
        
        return TokenResponse(
            success=True,
            token=access_token,
        )
    

    @staticmethod
    async def login_user(credentials: UserLogin) -> TokenResponse:
        result = await AuthDAO.check_user_credentials(credentials)
        
        if not result["success"]:
            raise unauthorized_ex
 
        user_id = await AuthDAO.get_user_id_by_username(credentials.username)

        access_token = create_access_token(user_id)
        refresh_token = create_refresh_token(user_id)
        
        # TODO: Сохранение refresh token в базу данных
        
        return TokenResponse(
            success=True,
            token=access_token,
        )
    
    
    @staticmethod
    def verify_access_token(token: str) -> Optional[dict]:
        payload = verify_token(token)
        if not payload:
            return None

        if payload.get("type") != "access":
            return None
        
        return payload