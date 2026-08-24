import Foundation

/// Protocol abstraction for executing network API requests using Swift Concurrency.
public protocol NetworkServiceProtocol: Sendable {
    /// Executes a request for a given endpoint and decodes the response payload to a Decodable type T.
    func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint, decoder: JSONDecoder) async throws -> T
    
    /// Executes a request for a given endpoint and returns the raw Data.
    func requestData(_ endpoint: APIEndpoint) async throws -> Data
}

public extension NetworkServiceProtocol {
    /// Default overload using standard JSONDecoder.
    func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
        try await request(endpoint, decoder: JSONDecoder())
    }
}
