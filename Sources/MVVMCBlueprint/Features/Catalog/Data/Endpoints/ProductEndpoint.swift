import Foundation

/// Feature API routes enum for Catalog feature conforming to APIEndpoint.
public enum ProductEndpoint: APIEndpoint, Sendable {
    case getProducts
    case getProductDetails(id: Int)
    
    public var baseURL: URL {
        return URL(string: "https://dummyjson.com")!
    }
    
    public var path: String {
        switch self {
        case .getProducts:
            return "/products"
        case .getProductDetails(let id):
            return "/products/\(id)"
        }
    }
    
    public var method: HTTPMethod {
        return .get
    }
    
    public var headers: [String: String]? {
        return ["Accept": "application/json"]
    }
    
    public var queryItems: [URLQueryItem]? {
        return nil
    }
    
    public var body: Data? {
        return nil
    }
}
