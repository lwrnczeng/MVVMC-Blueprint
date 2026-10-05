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
    
    func testAPIEndpoint_urlRequestGeneration_createsValidDummyJSONRequest() throws {
        // Given
        let endpoint = CheckoutEndpoint.getCart(id: 1)
        
        // When
        let request = try endpoint.urlRequest()
        
        // Then
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url?.absoluteString, "https://dummyjson.com/carts/1")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
    }
    
    func testMockNetworkService_decodesDummyCartDTOSuccessfully() async throws {
        // Given
        let jsonString = """
        {
            "id": 1,
            "products": [
                {
                    "id": 162,
                    "title": "Blue Frock",
                    "price": 29.99,
                    "quantity": 4,
                    "total": 119.96,
                    "discountPercentage": 12.13,
                    "discountedTotal": 105.41,
                    "thumbnail": "https://cdn.dummyjson.com/product-images/tops/blue-frock/thumbnail.webp"
                }
            ],
            "total": 119.96,
            "discountedTotal": 105.41,
            "userId": 1,
            "totalProducts": 1,
            "totalQuantity": 4
        }
        """
        let mockData = jsonString.data(using: .utf8)!
        let mockNetwork = MockNetworkService(mockResultData: mockData)
        let repository = OrderRepository(networkService: mockNetwork)
        
        // When
        let order = try await repository.fetchCart(id: 1)
        
        // Then
        XCTAssertEqual(order.items.count, 1)
        XCTAssertEqual(order.items.first?.name, "Blue Frock")
        XCTAssertEqual(order.subtotal, 119.96)
    }
    
    func testOrderRepository_handlesNetworkError_usesLocalFallbackFixture() async throws {
        // Given
        let mockNetwork = MockNetworkService(mockError: NetworkError.serverError)
        let repository = OrderRepository(networkService: mockNetwork)
        
        // When
        let fallbackOrder = try await repository.fetchCart(id: 1)
        
        // Then (Fallback loads local fixture)
        XCTAssertGreaterThan(fallbackOrder.items.count, 0)
    }
}
