from fastapi import HTTPException, status


unauthorized_ex = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED,
    detail="Unauthorized",
    headers={"WWW-Authenticate": "Bearer"},
)


forbidden_ex = HTTPException(
    status_code=status.HTTP_403_FORBIDDEN,
    detail="Forbidden",
    headers={"WWW-Authenticate": "Bearer"},
)