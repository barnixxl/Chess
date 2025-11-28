import base64
from pathlib import Path
from pydantic import Field
from pydantic_settings import BaseSettings


class AuthJWT(BaseSettings):
    private_key_path: Path | None = Field(default=Path("certs/jwt-private.pem"))
    public_key_path: Path | None = Field(default=Path("certs/jwt-public.pem"))
    
    private_key_base64: str | None = Field(default=None)
    public_key_base64: str | None = Field(default=None)
    
    algorithm: str = Field(default="RS256")
    access_token_expire_minutes: int = Field(default=60)
    refresh_token_expire_days: int = Field(default=30)
    
    def get_private_key(self) -> str:
        if self.private_key_base64:
            return base64.b64decode(self.private_key_base64).decode('utf-8')
        if self.private_key_path and self.private_key_path.exists():
            return self.private_key_path.read_text()
        raise ValueError(
            "JWT private key not configured."
        )
    
    def get_public_key(self) -> str:
        if self.public_key_base64:
            return base64.b64decode(self.public_key_base64).decode('utf-8')
        if self.public_key_path and self.public_key_path.exists():
            return self.public_key_path.read_text()
        raise ValueError(
            "JWT public key not configured."
        )
    
    class Config:
        env_prefix = "JWT_"
        case_sensitive = True


class Settings(BaseSettings):
    APP_HOST: str = Field(default='0.0.0.0')
    APP_PORT: int = Field(default=8080)
    
    POSTGRES_USER: str = Field(default='postgres')
    POSTGRES_PASSWORD: str = Field()
    POSTGRES_DB: str = Field(default='postgres')
    POSTGRES_PORT: int = Field(default=5433)
    POSTGRES_HOST: str = Field(default='localhost')

    auth_jwt: AuthJWT = Field(default_factory=AuthJWT)
    
    class Config:
        case_sensitive = True
        env_file = ".env"


settings = Settings()