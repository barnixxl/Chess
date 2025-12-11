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
    let bestWinTime: Double? // В секундах, может быть nil
    
    enum CodingKeys: String, CodingKey {
        case totalWins = "total_wins"
        case totalLosses = "total_losses"
        case bestWinTime = "best_win_time"
    }
}

class APIService {
    static let shared = APIService()
    
    // Базовый URL бэкенда (по умолчанию для локального Docker)
    // Можно изменить на нужный адрес
    private var baseURL: String {
        // Для Docker на локальной машине обычно используется localhost:PORT
        // Или IP адрес Docker контейнера
        return "http://89.169.38.200:8080" // Измените на ваш URL бэкенда
    }
    
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Login
    
    func login(username: String, password: String, completion: @escaping (Result<TokenResponse, APIError>) -> Void) {
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
            // Для отладки: выводим отправляемый запрос
            print("Login URL: \(url.absoluteString)")
            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                print("Login Request: \(jsonString)")
            }
        } catch {
            print("Encoding error: \(error)")
            completion(.failure(.decodingError))
            return
        }
        
        performRequest(request: request, completion: completion)
    }
    
    // MARK: - Register
    
    func register(username: String, password: String, completion: @escaping (Result<TokenResponse, APIError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/auth/register") else {
            completion(.failure(.invalidURL))
            return
        }
        
        let requestBody = RegisterRequest(username: username, password: password, avatar: nil)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(requestBody)
            // Для отладки: выводим отправляемый запрос
            print("Register URL: \(url.absoluteString)")
            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                print("Register Request: \(jsonString)")
            }
        } catch {
            print("Encoding error: \(error)")
            completion(.failure(.decodingError))
            return
        }
        
        performRequest(request: request, completion: completion)
    }
    
    // MARK: - Statistics
    
    func getStatistics(completion: @escaping (Result<StatisticsResponse, APIError>) -> Void) {
        guard let token = Storage.shared.authToken else {
            completion(.failure(.networkError("Требуется авторизация")))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/api/statistics") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        performRequest(request: request, completion: completion)
    }
    
    // MARK: - Private
    
    private func performRequest<T: Codable>(request: URLRequest, completion: @escaping (Result<T, APIError>) -> Void) {
        session.dataTask(with: request) { data, response, error in
            // Проверка на ошибку сети
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error.localizedDescription)))
                }
                return
            }
            
            // Проверка HTTP статус кода
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                print("HTTP Status Code: \(statusCode)")
                
                // Парсим ошибку если статус код не успешный
                if statusCode < 200 || statusCode >= 300 {
                    let errorMessage = self.parseErrorMessage(from: data)
                    print("Server Error: \(statusCode) - \(errorMessage ?? "Unknown error")")
                    DispatchQueue.main.async {
                        completion(.failure(.serverError(statusCode, errorMessage)))
                    }
                    return
                }
            }
            
            // Проверка наличия данных
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            // Декодирование ответа
            do {
                let decoder = JSONDecoder()
                // Для отладки: выводим сырой ответ
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("API Response: \(jsonString)")
                }
                let result = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch let decodingError {
                print("Decoding error: \(decodingError)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Failed to decode JSON: \(jsonString)")
                }
                DispatchQueue.main.async {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    private func parseErrorMessage(from data: Data?) -> String? {
        guard let data = data else { return nil }
        
        // Если это текстовая ошибка
        if let text = String(data: data, encoding: .utf8) {
            // Проверяем, не является ли это JSON
            if text.hasPrefix("{") || text.hasPrefix("[") {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // FastAPI часто возвращает детали ошибок в массиве detail
                    if let detail = json["detail"] as? [[String: Any]] {
                        let messages = detail.compactMap { errorDict -> String? in
                            if let msg = errorDict["msg"] as? String,
                               let loc = errorDict["loc"] as? [Any] {
                                let locPath = loc.map { "\($0)" }.joined(separator: ".")
                                return "\(locPath): \(msg)"
                            }
                            return nil
                        }
                        if !messages.isEmpty {
                            return messages.joined(separator: "; ")
                        }
                    }
                    // Простая строка detail
                    if let detail = json["detail"] as? String {
                        return detail
                    }
                    if let message = json["message"] as? String {
                        return message
                    }
                    if let error = json["error"] as? String {
                        return error
                    }
                }
            } else {
                // Просто текстовое сообщение
                return text
            }
        }
        
        return nil
    }
}

