import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)
    case serverError(Int, String?)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .noData:
            return "Нет данных от сервера"
        case .decodingError:
            return "Ошибка обработки ответа"
        case .networkError(let message):
            return "Ошибка сети: \(message)"
        case .serverError(let code, let message):
            return message ?? "Ошибка сервера: \(code)"
        }
    }
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct RegisterRequest: Codable {
    let username: String
    let password: String
    let avatar: String?
    
    init(username: String, password: String, avatar: String? = nil) {
        self.username = username
        self.password = password
        self.avatar = avatar
    }
    
    enum CodingKeys: String, CodingKey {
        case username
        case password
        case avatar
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
        // Кодируем avatar только если оно не nil
        if let avatar = avatar {
            try container.encode(avatar, forKey: .avatar)
        }
    }
}

struct TokenResponse: Codable {
    let success: Bool
    let token: String
}

// MARK: - Statistics

struct StatisticsResponse: Codable {
    let totalWins: Int
    let totalLosses: Int
    let totalDraws: Int?
    let bestWinTime: Double? // В секундах, может быть nil
    let totalGames: Int?
    let winRate: Double? // Процент побед (0-100)
    let averageGameTime: Double? // Среднее время игры в секундах
    
    enum CodingKeys: String, CodingKey {
        case totalWins = "total_wins"
        case totalLosses = "total_losses"
        case totalDraws = "total_draws"
        case bestWinTime = "best_win_time"
        case totalGames = "total_games"
        case winRate = "win_rate"
        case averageGameTime = "average_game_time"
    }
    
    // Инициализатор с дефолтными значениями для опциональных полей
    init(totalWins: Int, totalLosses: Int, totalDraws: Int? = nil, bestWinTime: Double? = nil, totalGames: Int? = nil, winRate: Double? = nil, averageGameTime: Double? = nil) {
        self.totalWins = totalWins
        self.totalLosses = totalLosses
        self.totalDraws = totalDraws
        self.bestWinTime = bestWinTime
        self.totalGames = totalGames
        self.winRate = winRate
        self.averageGameTime = averageGameTime
    }
}

// MARK: - Update Requests

struct UpdateNicknameRequest: Codable {
    let newNickname: String
    
    enum CodingKeys: String, CodingKey {
        case newNickname = "new_nickname"
    }
}

struct UpdatePasswordRequest: Codable {
    let currentPassword: String
    let newPassword: String
    
    enum CodingKeys: String, CodingKey {
        case currentPassword = "current_password"
        case newPassword = "new_password"
    }
}

struct SuccessResponse: Codable {
    let success: Bool
    let message: String?
    
    init(success: Bool, message: String?) {
        self.success = success
        self.message = message
    }
    
    // Custom decoding to handle cases like {"message": "Success"} without "success": true
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message = try? container.decode(String.self, forKey: .message)
        
        // Try decoding success, if missing but message exists, assume true
        if let successVal = try? container.decode(Bool.self, forKey: .success) {
            self.success = successVal
        } else {
            self.success = true // Default to true if only message is returned (typical 200 OK behavior for simple APIs)
        }
    }
}

// MARK: - Leaderboard

struct LeaderboardEntry: Codable {
    let username: String
    let wins: Int
    let losses: Int?
    let draws: Int?
    let rank: Int
    let totalGames: Int?
    let winRate: Double?
    
    enum CodingKeys: String, CodingKey {
        case username
        case wins = "total_wins"
        case losses = "total_losses"
        case draws = "total_draws"
        case rank
        case totalGames = "total_games"
        case winRate = "win_rate"
    }
}

struct LeaderboardResponse: Codable {
    let leaders: [LeaderboardEntry]
    
    init(leaders: [LeaderboardEntry]) {
        self.leaders = leaders
    }
    
    // Поддержка разных форматов ответа от API
    init(from decoder: Decoder) throws {
        // Пробуем декодировать как массив напрямую
        if let container = try? decoder.singleValueContainer(),
           let array = try? container.decode([LeaderboardEntry].self) {
            self.leaders = array
            return
        }
        
        // Если не массив, пробуем как объект с полем leaders или leaderboard или ranking
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let leadersArray = try? container.decode([LeaderboardEntry].self, forKey: .leaders) {
            self.leaders = leadersArray
        } else if let leaderboardArray = try? container.decode([LeaderboardEntry].self, forKey: .leaderboard) {
            self.leaders = leaderboardArray
        } else if let rankingArray = try? container.decode([LeaderboardEntry].self, forKey: .ranking) {
            self.leaders = rankingArray
        } else {
            self.leaders = []
        }
    }
    
    // Реализация encode для соответствия Codable (хотя не используется)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(leaders, forKey: .leaders)
    }
    
    enum CodingKeys: String, CodingKey {
        case leaders
        case leaderboard
        case ranking
    }
}

class APIService {
    static let shared = APIService()
    
    // Базовый URL бэкенда
    private var baseURL: String {
        return "http://89.169.38.200:8080"
    }
    
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Login
    
    func login(username: String, password: String, completion: @escaping (Result<TokenResponse, APIError>) -> Void) {
        // Correct endpoint per docs: /api/auth/login
        guard let url = URL(string: "\(baseURL)/api/auth/login") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let requestBody = LoginRequest(username: username, password: password)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(requestBody)
            print("Login URL: \(url.absoluteString)")
        } catch {
            print("Encoding error: \(error)")
            completion(.failure(.decodingError))
            return
        }
        
        performRequest(request: request, completion: completion)
    }
    
    // MARK: - Register
    
    func register(username: String, password: String, completion: @escaping (Result<TokenResponse, APIError>) -> Void) {
        // Correct endpoint per docs: /api/auth/register
        guard let url = URL(string: "\(baseURL)/api/auth/register") else {
            completion(.failure(.invalidURL))
            return
        }
        
        // API requires avatar field, sending empty string or default if nil not supported nicely by struct, 
        // but let's assume valid string or nil is fine. 
        // Docs say avatar is string.
        let requestBody = RegisterRequest(username: username, password: password, avatar: "default")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(requestBody)
            print("Register URL: \(url.absoluteString)")
        } catch {
            print("Encoding error: \(error)")
            completion(.failure(.decodingError))
            return
        }
        
        performRequest(request: request, completion: completion)
    }
    
    // MARK: - Statistics
    
    // Note: API only has /account/profile which returns { username, rating, avatar }
    // It does not have wins/losses. We will map rating.
    struct ProfileResponse: Codable {
        let username: String
        let wins: Int?
        let losses: Int?
        let draws: Int?
        let winrate: Double?
        let best_win_time: Double?
        
        enum CodingKeys: String, CodingKey {
            case username
            case wins
            case losses
            case draws
            case winrate
            case best_win_time
        }
    }
    
    func getStatistics(completion: @escaping (Result<StatisticsResponse, APIError>) -> Void) {
        guard let token = Storage.shared.authToken else {
            completion(.failure(.networkError("Требуется авторизация")))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/account/profile") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("🔍 Fetching Profile for Stats: \(url.absoluteString)")
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.networkError(error.localizedDescription))) }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let profile = try decoder.decode(ProfileResponse.self, from: data)
                
                // Construct fake statistics response with available data
                // We don't have totalWins/losses, so we set them to 0 or estimates
                // Ideally this should be fixed on Backend
                let stats = StatisticsResponse(
                    totalWins: profile.wins ?? 0, 
                    totalLosses: profile.losses ?? 0, 
                    totalDraws: profile.draws ?? 0, 
                    bestWinTime: profile.best_win_time, 
                    totalGames: (profile.wins ?? 0) + (profile.losses ?? 0) + (profile.draws ?? 0), 
                    winRate: profile.winrate, 
                    averageGameTime: 0
                )
                // TODO: Add rating to StatisticsResponse or separate call
                
                DispatchQueue.main.async {
                    completion(.success(stats))
                }
            } catch {
                print("Decoding Profile Error: \(error)")
                DispatchQueue.main.async { completion(.failure(.decodingError)) }
            }
        }.resume()
    }
    
    
    // MARK: - Update Nickname
    
    // API: POST /account/username Body: { "new_username": "string" }
    struct UpdateUsernameRequest: Codable {
        let new_username: String
    }
    
    func updateNickname(newNickname: String, completion: @escaping (Result<SuccessResponse, APIError>) -> Void) {
        guard let token = Storage.shared.authToken else {
            completion(.failure(.networkError("Требуется авторизация")))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/account/username") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let requestBody = UpdateUsernameRequest(new_username: newNickname)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST" 
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(requestBody)
        } catch {
            completion(.failure(.decodingError))
            return
        }
        
        performRequest(request: request, completion: completion)
    }
    
    // MARK: - Update Password
    
    // API: POST /account/password Body: { "old_password": "...", "new_password": "..." }
    struct UpdatePasswordRequestAPI: Codable {
        let old_password: String
        let new_password: String
    }
    
    func updatePassword(currentPassword: String, newPassword: String, completion: @escaping (Result<SuccessResponse, APIError>) -> Void) {
        guard let token = Storage.shared.authToken else {
            completion(.failure(.networkError("Требуется авторизация")))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/account/password") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let requestBody = UpdatePasswordRequestAPI(old_password: currentPassword, new_password: newPassword)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(requestBody)
        } catch {
            completion(.failure(.decodingError))
            return
        }
        
        performRequest(request: request, completion: completion)
    }
    
    // MARK: - Leaderboard
    
    // API: GET /ranking/ -> returns [ {username, rating} ]
    struct RankingUser: Codable {
        let username: String
        let rating: Int?
    }
    
    struct RankingResponse: Codable {
        let ranking: [RankingUser]
    }
    
    func getLeaderboard(completion: @escaping (Result<LeaderboardResponse, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/ranking/") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        print("🔍 Fetching Leaderboard: \(url.absoluteString)")
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.networkError(error.localizedDescription))) }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }
            
            do {
                if let json = String(data: data, encoding: .utf8) {
                    print("Ranking JSON: \(json)")
                }
                
                let decoder = JSONDecoder()
                var rankings: [RankingUser] = []
                
                // Try decoding as wrapper first {"ranking": [...]}
                if let wrapper = try? decoder.decode(RankingResponse.self, from: data) {
                    rankings = wrapper.ranking
                } else {
                    // Fallback to array directly [...]
                    rankings = try decoder.decode([RankingUser].self, from: data)
                }
                
                // Convert [RankingUser] to LeaderboardResponse (which expects [LeaderboardEntry])
                var entries: [LeaderboardEntry] = []
                for (index, user) in rankings.enumerated() {
                    let entry = LeaderboardEntry(
                        username: user.username,
                        wins: user.rating ?? 0, // Map rating to wins so it is displayed as score
                        losses: 0,
                        draws: 0, 
                        rank: index + 1,
                        totalGames: 0,
                        winRate: 0.0
                    )
                    entries.append(entry)
                }
                
                let response = LeaderboardResponse(leaders: entries)
                DispatchQueue.main.async {
                    completion(.success(response))
                }
            } catch {
                print("Decoding Ranking Error: \(error)")
                DispatchQueue.main.async { completion(.failure(.decodingError)) }
            }
        }.resume()
    }
    
    // MARK: - Game Results
    
    // API: POST /game/ 
    // Body: { "isWin": bool, "isDraw": bool, "eloBefore": int, "eloAfter": int, "result": "string", "duration": double }
    struct GameResultRequestAPI: Codable {
        let isWin: Bool
        let isDraw: Bool
        let eloBefore: Int
        let eloAfter: Int
        let result: String
        let duration: Double // Time in seconds
    }
    
    func submitGameResult(isWin: Bool, isDraw: Bool, eloBefore: Int, eloAfter: Int, duration: Double, completion: @escaping (Result<SuccessResponse, APIError>) -> Void) {
        guard let token = Storage.shared.authToken else {
            completion(.failure(.networkError("Требуется авторизация")))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/game/") else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Determine result string
        let resultString: String
        if isDraw { resultString = "draw" }
        else if isWin { resultString = "win" }
        else { resultString = "lose" }
        
        let requestBody = GameResultRequestAPI(isWin: isWin, isDraw: isDraw, eloBefore: eloBefore, eloAfter: eloAfter, result: resultString, duration: duration)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(requestBody)
        } catch {
             completion(.failure(.decodingError))
             return
        }
        
        performRequest(request: request, completion: completion)
    }
    
    // MARK: - Private
    
    private func performRequest<T: Codable>(request: URLRequest, completion: @escaping (Result<T, APIError>) -> Void) {
        print("🌐 Request: \(request.httpMethod!) \(request.url!)")
        if let body = request.httpBody, let str = String(data: body, encoding: .utf8) {
            print("📦 Body: \(str)")
        }
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(.failure(.networkError(error.localizedDescription))) }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 401 {
                     DispatchQueue.main.async { completion(.failure(.serverError(401, "Unauthorized"))) }
                     return
                }
                
                if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                    let errorMessage = self.parseErrorMessage(from: data)
                    print("❌ Server Error: \(errorMessage ?? "")")
                    DispatchQueue.main.async { completion(.failure(.serverError(httpResponse.statusCode, errorMessage))) }
                    return
                }
                
                // Special case for Empty response (void)
                if data == nil || data!.isEmpty {
                     // If T is SuccessResponse, we can synthesize one
                     if T.self == SuccessResponse.self {
                         let success = SuccessResponse(success: true, message: "OK")
                         DispatchQueue.main.async { completion(.success(success as! T)) }
                         return
                     }
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }
            
            do {
                if let str = String(data: data, encoding: .utf8) {
                    print("✅ Response: \(str)")
                }
                
                // If expecting SuccessResponse but received simple OK or empty, handle it?
                // But generally we should be fine if structs match.
                
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async { completion(.success(result)) }
            } catch {
                // If we failed to decode T, but maybe it was a success message?
                // Check if T is SuccessResponse and data was just null or something wrapped
                print("❌ Decoding error: \(error)")
                DispatchQueue.main.async { completion(.failure(.decodingError)) }
            }
        }.resume()
    }
    
    private func parseErrorMessage(from data: Data?) -> String? {
        guard let data = data else { return nil }
        if let text = String(data: data, encoding: .utf8) {
            return text
        }
        return nil
    }
}

