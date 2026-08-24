import Foundation

/// Feature API routes enum conforming to APIEndpoint.
public enum CheckoutEndpoint: APIEndpoint, Sendable {
    case submitOrder(OrderDTO)
    case processPayment(orderId: UUID, amount: Decimal)
    
    public var baseURL: URL {
        // Base API URL configuration (can be read from App Environment / Config)
        return URL(string: "https://api.checkout.example.com/v1")!
    }
    
    public var path: String {
        switch self {
        case .submitOrder:
            return "/orders"
        case .processPayment(let orderId, _):
            return "/orders/\(orderId.uuidString)/payments"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .submitOrder, .processPayment:
            return .post
        }
    }
    
    public var headers: [String: String]? {
        return [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
    
    public var queryItems: [URLQueryItem]? {
        return nil
    }
    
    public var body: Data? {
        let encoder = JSONEncoder()
        switch self {
        case .submitOrder(let dto):
            return try? encoder.encode(dto)
        case .processPayment(_, let amount):
            struct PaymentPayload: Encodable {
                let amount: Double
            }
            let payload = PaymentPayload(amount: NSDecimalNumber(decimal: amount).doubleValue)
            return try? encoder.encode(payload)
        }
    }
}
