import XCTest
@testable import MVVMCBlueprint

/// Mock NetworkService implementing NetworkServiceProtocol for unit testing.
public final class MockNetworkService: NetworkServiceProtocol, @unchecked Sendable {
    public var mockResultData: Data?
    public var mockError: NetworkError?
    
    public init(mockResultData: Data? = nil, mockError: NetworkError? = nil) {
        self.mockResultData = mockResultData
        self.mockError = mockError
    }
    
    public func requestData(_ endpoint: APIEndpoint) async throws -> Data {
        if let error = mockError {
            throw error
        }
        guard let data = mockResultData else {
            throw NetworkError.noData
        }
        return data
    }
    
    public func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint, decoder: JSONDecoder) async throws -> T {
        let data = try await requestData(endpoint)
        return try decoder.decode(T.self, from: data)
    }
}

final class NetworkServiceTests: XCTestCase {
    
    func testAPIEndpoint_urlRequestGeneration_createsValidRequest() throws {
        // Given
        let dto = OrderDTO(orderId: "12345", totalAmount: 99.9, status: "NEW", createdAt: "2026-08-22")
        let endpoint = CheckoutEndpoint.submitOrder(dto)
        
        // When
        let request = try endpoint.urlRequest()
        
        // Then
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.absoluteString, "https://api.checkout.example.com/v1/orders")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNotNil(request.httpBody)
    }
    
    func testMockNetworkService_decodesResponseSuccessfully() async throws {
        // Given
        let jsonString = """
        {
            "orderId": "B8B82633-2F4F-4B8F-8F8D-9E9F00000000",
            "totalAmount": 150.0,
            "status": "SUBMITTED",
            "createdAt": "2026-08-22T00:00:00Z"
        }
        """
        let mockData = jsonString.data(using: .utf8)!
        let mockNetwork = MockNetworkService(mockResultData: mockData)
        let repository = OrderRepository(networkService: mockNetwork)
        
        let order = Order(id: UUID(uuidString: "B8B82633-2F4F-4B8F-8F8D-9E9F00000000")!, items: [], subtotal: 150.0)
        
        // When
        let resultOrder = try await repository.submitOrder(order)
        
        // Then
        XCTAssertEqual(resultOrder.id.uuidString, "B8B82633-2F4F-4B8F-8F8D-9E9F00000000")
        XCTAssertEqual(resultOrder.subtotal, 150.0)
    }
    
    func testOrderRepository_handlesNetworkError_usesFallbackGracefully() async throws {
        // Given
        let mockNetwork = MockNetworkService(mockError: NetworkError.serverError)
        let repository = OrderRepository(networkService: mockNetwork)
        let order = Order(id: UUID(), items: [], subtotal: 45.0)
        
        // When
        let resultOrder = try await repository.submitOrder(order)
        
        // Then (Fallback handles offline baseline)
        XCTAssertEqual(resultOrder.subtotal, 45.0)
    }
}
