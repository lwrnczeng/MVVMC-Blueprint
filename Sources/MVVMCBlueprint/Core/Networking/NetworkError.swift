import Foundation

/// Exhaustive error types for Network Operations conforming to LocalizedError & Equatable.
public enum NetworkError: Error, LocalizedError, Equatable, Sendable {
    case invalidURL
    case requestFailed(description: String)
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingError(description: String)
    case noData
    case unauthorized
    case serverError
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .requestFailed(let description):
            return "Network request failed: \(description)"
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .httpError(let statusCode, _):
            return "HTTP Error with status code: \(statusCode)."
        case .decodingError(let description):
            return "Failed to decode response: \(description)"
        case .noData:
            return "Server returned empty response body."
        case .unauthorized:
            return "Authentication required or session expired."
        case .serverError:
            return "Server encountered an internal error."
        }
    }
}
