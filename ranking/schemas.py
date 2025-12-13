from typing import List
from pydantic import BaseModel


class Rank(BaseModel):
    username: str
    rating: int

class ListRanking(BaseModel):
    ranking: List[Rank]