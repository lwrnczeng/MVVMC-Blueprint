import Foundation

/// Concrete URLSession engine implementing NetworkServiceProtocol.
public final class URLSessionNetworkService: NetworkServiceProtocol, Sendable {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func requestData(_ endpoint: APIEndpoint) async throws -> Data {
        let request = try endpoint.urlRequest()
        
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.requestFailed(description: error.localizedDescription)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return data
        case 401:
            throw NetworkError.unauthorized
        case 500...599:
            throw NetworkError.serverError
        default:
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
    }
    
    public func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint, decoder: JSONDecoder) async throws -> T {
        let data = try await requestData(endpoint)
        
        guard !data.isEmpty else {
            throw NetworkError.noData
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingError(description: decodingError.localizedDescription)
        } catch {
            throw NetworkError.decodingError(description: error.localizedDescription)
        }
    }
}
