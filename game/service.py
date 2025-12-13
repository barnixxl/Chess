from .model import GameDAO
from .schemas import GameRequest, GameResponse, GameResult


class GameService:
    @staticmethod
    async def save_game(game: GameRequest, payload: dict):
        # Сохраняем игру
        user_id = int(payload.get("sub"))
        await GameDAO.save_game(user_id, game.result, game.win_time)

        ranking = await GameDAO.fetch_current_ranking(user_id)
        rating = ranking["rating"]
        best_win_time = ranking["best_win_time"]

        rating_change, new_best_win_time = await GameService._calculate_rating_change(game, best_win_time, user_id)
        new_rating = rating + rating_change

        # Обновляем рейтинг и рекорд
        await GameDAO.update_rating(new_rating, new_best_win_time, user_id)

        return GameResponse(rating=new_rating, rating_change=rating_change, best_win_time=new_best_win_time)

    @staticmethod
    async def _calculate_rating_change(game: GameRequest, best_win_time: int, user_id: int) -> tuple[int, int | None]:
        recent_games = await GameDAO.fetch_recent_games(user_id)
        streak = [g["result"] for g in recent_games]

        rating_change = 0
        new_best_win_time = best_win_time

        if game.result == GameResult.WIN:
            rating_change = 15
            if streak.count("lose") >= 5:
                rating_change += 30
            if game.win_time is not None and (best_win_time is None or game.win_time < best_win_time):
                rating_change += 10
                new_best_win_time = game.win_time
        elif game.result == GameResult.LOSE:
            rating_change = -15
            if streak.count("win") >= 5:
                rating_change -= 30
        elif game.result == GameResult.DRAW:
            rating_change = 1
            if streak.count("lose") >= 5:
                rating_change += 5
            if streak.count("win") >= 5:
                rating_change -= 5

        return rating_change, new_best_win_time


        
