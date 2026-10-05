import Foundation

/// Feature API routes enum conforming to APIEndpoint (connecting to DummyJSON Carts API).
public enum CheckoutEndpoint: APIEndpoint, Sendable {
    case getCart(id: Int)
    case getCarts
    case addCart(userId: Int, products: [AddCartProductItem])
    case processPayment(orderId: UUID, amount: Decimal)
    
    public struct AddCartProductItem: Codable, Sendable {
        public let id: Int
        public let quantity: Int
        
        public init(id: Int, quantity: Int) {
            self.id = id
            self.quantity = quantity
        }
    }
    
    public var baseURL: URL {
        return URL(string: "https://dummyjson.com")!
    }
    
    public var path: String {
        switch self {
        case .getCart(let id):
            return "/carts/\(id)"
        case .getCarts:
            return "/carts"
        case .addCart:
            return "/carts/add"
        case .processPayment(let orderId, _):
            return "/carts/\(orderId.uuidString)/pay"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getCart, .getCarts:
            return .get
        case .addCart, .processPayment:
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
        case .addCart(let userId, let products):
            struct AddCartPayload: Encodable {
                let userId: Int
                let products: [AddCartProductItem]
            }
            return try? encoder.encode(AddCartPayload(userId: userId, products: products))
        case .processPayment(_, let amount):
            struct PaymentPayload: Encodable {
                let amount: Double
            }
            return try? encoder.encode(PaymentPayload(amount: NSDecimalNumber(decimal: amount).doubleValue))
        case .getCart, .getCarts:
            return nil
        }
    }
}
