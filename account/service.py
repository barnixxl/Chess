from .model import AccountDAO
from .schemas import ChangePassword, ChangeUsername

class AccountService:
    @staticmethod
    async def get_profile(user_id: int):
        return await AccountDAO.get_profile(user_id)

    @staticmethod
    async def change_password(user_id: int, data: ChangePassword):
        return await AccountDAO.change_password(user_id, data)

    @staticmethod
    async def change_username(user_id: int, data: ChangeUsername):
        return await AccountDAO.change_username(user_id, data)
