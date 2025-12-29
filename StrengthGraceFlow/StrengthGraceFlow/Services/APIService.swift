//
//  APIService.swift
//  StrengthGraceFlow
//
//  Backend API service for communicating with Railway backend
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case unauthorized
    case notFound
    case validationError(String)
    case serverError(Int)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .unauthorized:
            return "Please sign in again"
        case .notFound:
            return "Resource not found"
        case .validationError(let message):
            return message
        case .serverError(let code):
            return "Server error: \(code)"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

@MainActor
class APIService {
    static let shared = APIService()

    private let baseURL = "https://strength-gace-flow-production.up.railway.app"

    private init() {}

    // MARK: - User Profile

    func getUserProfile() async throws -> UserProfileResponse {
        return try await request(endpoint: "/api/v1/users/me", method: "GET")
    }

    func createUserProfile(data: CreateUserRequest) async throws -> UserProfileResponse {
        return try await request(endpoint: "/api/v1/users/me", method: "POST", body: data)
    }

    func updateUserProfile(data: UpdateUserRequest) async throws -> UserProfileResponse {
        return try await request(endpoint: "/api/v1/users/me", method: "PATCH", body: data)
    }

    // MARK: - Cycle

    func getCurrentCycle() async throws -> CycleInfoResponse {
        return try await request(endpoint: "/api/v1/cycle/current", method: "GET")
    }

    func logPeriod(startDate: Date, notes: String? = nil) async throws -> CycleInfoResponse {
        let data = LogPeriodRequest(startDate: startDate, notes: notes)
        return try await request(endpoint: "/api/v1/cycle/log-period", method: "POST", body: data)
    }

    func getCycleHistory(limit: Int = 12) async throws -> CycleHistoryResponse {
        return try await request(endpoint: "/api/v1/cycle/history?limit=\(limit)", method: "GET")
    }

    func getCyclePredictions(days: Int = 30) async throws -> CyclePredictionsResponse {
        return try await request(endpoint: "/api/v1/cycle/predictions?days=\(days)", method: "GET")
    }

    func updateCycleEntry(cycleId: String, data: UpdateCycleEntryRequest) async throws -> CycleData {
        return try await request(
            endpoint: "/api/v1/cycle/history/\(cycleId)",
            method: "PATCH",
            body: data
        )
    }

    func deleteCycleEntry(cycleId: String) async throws {
        let _: EmptyResponse = try await request(
            endpoint: "/api/v1/cycle/history/\(cycleId)",
            method: "DELETE"
        )
    }

    // MARK: - Recommendations (Basic - will expand later)

    func getTodayRecommendations() async throws -> DailyRecommendationResponse {
        return try await request(endpoint: "/api/v1/recommendations/today", method: "GET")
    }

    // MARK: - Energy Tracking

    func logEnergy(date: Date, score: Int, notes: String? = nil) async throws -> EnergyLogResponse {
        let data = LogEnergyRequest(date: date, score: score, notes: notes)
        return try await request(endpoint: "/api/v1/energy/log", method: "POST", body: data)
    }

    func getTodayEnergy() async throws -> EnergyLogResponse {
        return try await request(endpoint: "/api/v1/energy/today", method: "GET")
    }

    func getEnergyHistory(days: Int = 30) async throws -> EnergyHistoryResponse {
        return try await request(endpoint: "/api/v1/energy/history?days=\(days)", method: "GET")
    }

    // MARK: - Generic Request

    private func request<T: Decodable>(
        endpoint: String,
        method: String,
        body: Encodable? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add auth token
        if let token = try? await AuthService.shared.getIdToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add body
        if let body = body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)

            #if DEBUG
            // Log request body for debugging
            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                print("📤 API Request to \(endpoint):")
                print(jsonString)
            }
            #endif
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }

            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: data)
            case 401:
                throw APIError.unauthorized
            case 404:
                throw APIError.notFound
            case 422:
                // Validation error - try to parse error message from response
                if let errorMessage = try? JSONDecoder().decode([String: String].self, from: data),
                   let detail = errorMessage["detail"] {
                    #if DEBUG
                    print("❌ 422 Validation Error: \(detail)")
                    #endif
                    throw APIError.validationError(detail)
                }
                #if DEBUG
                if let responseString = String(data: data, encoding: .utf8) {
                    print("❌ 422 Response: \(responseString)")
                }
                #endif
                throw APIError.validationError("Please check your input and try again")
            default:
                #if DEBUG
                print("❌ Server error \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
                #endif
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch is DecodingError {
            throw APIError.decodingError
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - Request Models

struct CreateUserRequest: Codable {
    let displayName: String?
    let fitnessLevel: String?
    let goals: [String]
    let averageCycleLength: Int
    let averagePeriodLength: Int
    let cycleTrackingEnabled: Bool
    let notificationsEnabled: Bool
    let initialCycleDates: [Date]?

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case fitnessLevel = "fitness_level"
        case goals
        case averageCycleLength = "average_cycle_length"
        case averagePeriodLength = "average_period_length"
        case cycleTrackingEnabled = "cycle_tracking_enabled"
        case notificationsEnabled = "notifications_enabled"
        case initialCycleDates = "initial_cycle_dates"
    }
}

struct UpdateUserRequest: Codable {
    var displayName: String?
    var fitnessLevel: String?
    var goals: [String]?
    var averageCycleLength: Int?
    var averagePeriodLength: Int?
    var cycleTrackingEnabled: Bool?
    var notificationsEnabled: Bool?
    var lastPeriodStartDate: Date?

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case fitnessLevel = "fitness_level"
        case goals
        case averageCycleLength = "average_cycle_length"
        case averagePeriodLength = "average_period_length"
        case cycleTrackingEnabled = "cycle_tracking_enabled"
        case notificationsEnabled = "notifications_enabled"
        case lastPeriodStartDate = "last_period_start_date"
    }
}

struct LogPeriodRequest: Codable {
    let startDate: Date
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case notes
    }
}

struct UpdateCycleEntryRequest: Codable {
    var startDate: Date?
    var periodEndDate: Date?
    var notes: String?

    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case periodEndDate = "period_end_date"
        case notes
    }
}

struct EmptyResponse: Codable {}

// MARK: - Response Models

struct UserProfileResponse: Codable {
    let user: UserProfile
}

struct UserProfile: Codable {
    let id: String
    let email: String?
    let displayName: String?
    let fitnessLevel: String?
    let goals: [String]
    let averageCycleLength: Int
    let averagePeriodLength: Int
    let cycleTrackingEnabled: Bool
    let notificationsEnabled: Bool
    let lastPeriodStartDate: Date?
    let subscriptionStatus: String
    let onboardingCompleted: Bool
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case fitnessLevel = "fitness_level"
        case goals
        case averageCycleLength = "average_cycle_length"
        case averagePeriodLength = "average_period_length"
        case cycleTrackingEnabled = "cycle_tracking_enabled"
        case notificationsEnabled = "notifications_enabled"
        case lastPeriodStartDate = "last_period_start_date"
        case subscriptionStatus = "subscription_status"
        case onboardingCompleted = "onboarding_completed"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CycleInfoResponse: Codable {
    let cycle: CycleInfo
    let lastPeriodStart: Date
    let averageCycleLength: Int
    let averagePeriodLength: Int

    enum CodingKeys: String, CodingKey {
        case cycle
        case lastPeriodStart = "last_period_start"
        case averageCycleLength = "average_cycle_length"
        case averagePeriodLength = "average_period_length"
    }
}

struct CycleInfo: Codable {
    let currentPhase: String
    let cycleDay: Int
    let daysUntilNextPhase: Int
    let nextPhase: String
    let confidence: String
    let phaseDisplayName: String
    let phaseDescription: String
    let recommendedIntensity: String

    enum CodingKeys: String, CodingKey {
        case currentPhase = "current_phase"
        case cycleDay = "cycle_day"
        case daysUntilNextPhase = "days_until_next_phase"
        case nextPhase = "next_phase"
        case confidence
        case phaseDisplayName = "phase_display_name"
        case phaseDescription = "phase_description"
        case recommendedIntensity = "recommended_intensity"
    }
}

struct CycleHistoryResponse: Codable {
    let cycles: [CycleData]
    let averageCycleLength: Int
    let totalCyclesLogged: Int

    enum CodingKeys: String, CodingKey {
        case cycles
        case averageCycleLength = "average_cycle_length"
        case totalCyclesLogged = "total_cycles_logged"
    }
}

struct CycleData: Codable {
    let id: String
    let startDate: Date
    let endDate: Date?
    let cycleLength: Int?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case id
        case startDate = "start_date"
        case endDate = "end_date"
        case cycleLength = "cycle_length"
        case notes
    }
}

struct CyclePredictionsResponse: Codable {
    let predictions: [PhasePrediction]
    let nextPeriodStart: Date?

    enum CodingKeys: String, CodingKey {
        case predictions
        case nextPeriodStart = "next_period_start"
    }
}

struct PhasePrediction: Codable {
    let date: Date
    let phase: String
    let cycleDay: Int

    enum CodingKeys: String, CodingKey {
        case date
        case phase
        case cycleDay = "cycle_day"
    }
}

// MARK: - Recommendation Models (Basic - will expand later)

struct DailyRecommendationResponse: Codable {
    let dailyMessage: String
    let recommendations: [WorkoutRecommendation]
    let selfCareTip: String
    let phase: String
    let cycleDay: Int

    enum CodingKeys: String, CodingKey {
        case dailyMessage = "daily_message"
        case recommendations
        case selfCareTip = "self_care_tip"
        case phase
        case cycleDay = "cycle_day"
    }
}

struct WorkoutRecommendation: Codable {
    let workoutTitle: String
    let workoutId: String?
    let reason: String

    enum CodingKeys: String, CodingKey {
        case workoutTitle = "workout_title"
        case workoutId = "workout_id"
        case reason
    }
}

// MARK: - Energy Tracking Models

struct LogEnergyRequest: Codable {
    let date: Date
    let score: Int
    let notes: String?
}

struct EnergyLog: Codable {
    let id: String
    let userId: String
    let date: Date
    let score: Int
    let notes: String?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case date
        case score
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct EnergyLogResponse: Codable {
    let energy: EnergyLog
}

struct EnergyHistoryResponse: Codable {
    let entries: [EnergyLog]
    let averageScore: Double
    let totalLogs: Int

    enum CodingKeys: String, CodingKey {
        case entries
        case averageScore = "average_score"
        case totalLogs = "total_logs"
    }
}
