from fastapi import APIRouter, Depends, HTTPException
from auth.validation import get_current_auth_user
from .service import AccountService
from .schemas import AccountProfile, ChangePassword, ChangeUsername

router = APIRouter(prefix="/account", tags=["Account"])

@router.get("/profile", response_model=AccountProfile)
async def get_profile(payload: dict = Depends(get_current_auth_user)):
    user_id = int(payload.get("sub"))
    profile = await AccountService.get_profile(user_id)
    if not profile:
        raise HTTPException(status_code=404, detail="User not found")
    return profile

@router.post("/password")
async def change_password(data: ChangePassword, payload: dict = Depends(get_current_auth_user)):
    user_id = int(payload.get("sub"))
    result = await AccountService.change_password(user_id, data)
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result.get("error"))
    return {"message": "Success"}

@router.post("/username")
async def change_username(data: ChangeUsername, payload: dict = Depends(get_current_auth_user)):
    user_id = int(payload.get("sub"))
    result = await AccountService.change_username(user_id, data)
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result.get("error"))
    return {"message": "Success"}
