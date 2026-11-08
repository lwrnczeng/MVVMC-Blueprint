# MVVM-C Architecture - Dependency & Interaction Diagrams

This document contains visual diagrams (both **Mermaid** for native Markdown rendering and **PlantUML** for extension previews) illustrating the structural dependencies, protocol abstractions, and multi-feature cross-navigation flow of the **MVVM-C (Model-View-ViewModel-Coordinator)** architecture implementation in `MVVMC-Blueprint`.

---

## 1. High-Level Multi-Feature Architecture Layer Dependency

The rule of Multi-Feature Clean Architecture: **Features are strictly isolated from each other. ViewModels depend on Domain Use Case protocols (`FetchProductsUseCaseProtocol`), Use Cases depend on Domain Repository protocols (`ProductRepositoryProtocol`), and Repositories in the Data layer implement them (Dependency Inversion). Cross-feature transitions are coordinated by an App-level Root Coordinator (`AppCoordinator`) through Feature Delegate Protocols (`CatalogCoordinatorDelegate`).**

### Mermaid Diagram
```mermaid
graph TD
    subgraph Root ["App / Root Level"]
        AppView["AppContainerView"]
        AppCoord["AppCoordinator"]
    end

    subgraph Catalog ["Catalog Feature (Module 1)"]
        CatView["CatalogContainerView / ProductListView / DetailView"]
        CatCoord["CatalogCoordinator"]
        CatVM["CatalogViewModel"]
        CatDelegate["CatalogCoordinatorDelegate (Contract)"]
        FetchUseCaseProto["FetchProductsUseCaseProtocol"]
        FetchUseCase["FetchProductsUseCase"]
        ProdRepoProto["ProductRepositoryProtocol"]
        ProdRepo["ProductRepository"]
    end

    subgraph Checkout ["Checkout Feature (Module 2)"]
        CheckView["CheckoutContainerView / Input / Discount / Payment"]
        CheckCoord["CheckoutCoordinator"]
        CheckVM["CheckoutInputViewModel / DiscVM / PayVM"]
        OrderRepoProto["OrderRepositoryProtocol"]
        OrderRepo["OrderRepository"]
    end

    subgraph Core ["Core Infrastructure Layer"]
        Router["NavigationRouter (@MainActor)"]
        NetProto["NetworkServiceProtocol"]
        URLSessionEngine["URLSessionNetworkService"]
        APIEndpoint["APIEndpoint"]
    end

    %% Root Navigation & Cross-Feature Coordination
    AppView --> AppCoord
    AppCoord --> CatCoord
    AppCoord ..|> CatDelegate
    AppCoord --> CheckCoord
    CatCoord --> CatDelegate

    %% Catalog Internal (Strict Clean Architecture)
    CatView --> CatVM
    CatView --> CatCoord
    CatVM --> CatCoord
    CatVM --> FetchUseCaseProto
    FetchUseCase -.->|implements| FetchUseCaseProto
    FetchUseCase --> ProdRepoProto
    ProdRepo -.->|implements| ProdRepoProto
    ProdRepo --> NetProto

    %% Checkout Internal
    CheckView --> CheckCoord
    CheckVM --> CheckCoord
    CheckVM --> OrderRepoProto
    OrderRepo -.->|implements| OrderRepoProto
    OrderRepo --> NetProto

    URLSessionEngine -.->|implements| NetProto
```

### PlantUML Diagram
```plantuml
@startuml LayerDependencies
skinparam packageBackgroundColor #F8F9FA
skinparam packageBorderColor #4A90E2

package "App / Root Level" #FAF0E6 {
    [AppContainerView]
    [AppCoordinator]
}

package "Catalog Feature (Module 1)" #EBF5FB {
    package "Catalog UI" {
        [CatalogContainerView]
        [ProductListView]
        [ProductDetailView]
    }
    package "Catalog Presentation" {
        [CatalogViewModel]
        [CatalogCoordinator]
        [CatalogCoordinatorDelegate] as CatDelegate
    }
    package "Catalog Domain" {
        [FetchProductsUseCaseProtocol] as FetchUseCaseProto
        [FetchProductsUseCase]
        [ProductRepositoryProtocol] as ProdRepoProto
        [Product Model] as Product
    }
    package "Catalog Data" {
        [ProductRepository]
        [ProductEndpoint]
        [ProductDTO]
    }
}

package "Checkout Feature (Module 2)" #FDF2E9 {
    package "Checkout UI" {
        [CheckoutContainerView]
        [CheckoutInputView]
        [DiscountView]
        [PaymentView]
    }
    package "Checkout Presentation" {
        [CheckoutCoordinator]
        [CheckoutCoordinatorProtocol] as CoordProto
        [CheckoutInputViewModel]
        [DiscountViewModel]
        [PaymentViewModel]
    }
    package "Checkout Domain" {
        [OrderRepositoryProtocol] as OrderRepoProto
        [CalculateDiscountUseCaseProtocol] as CalcDiscountProto
        [CalculateDiscountUseCase]
        [ProcessPaymentUseCaseProtocol] as ProcessPayProto
        [ProcessPaymentUseCase]
        [Order Model] as Order
        [Discount Model] as Discount
        [PaymentResult Model] as PaymentResult
    }
    package "Checkout Data" {
        [OrderRepository]
        [CheckoutEndpoint]
        [DummyCartDTO]
        [OrderDTO]
    }
}

package "Core Infrastructure Layer" #F5EEF8 {
    [NavigationRouter]
    [NetworkServiceProtocol] as NetProto
    [URLSessionNetworkService]
    [APIEndpoint]
}

' Root Orchestration & Cross-Feature Communication (Zero Direct Feature Coupling)
[AppContainerView] --> [AppCoordinator]
[AppCoordinator] --> [CatalogCoordinator]
[AppCoordinator] ..|> CatDelegate
[AppCoordinator] --> [CheckoutCoordinator]
[CatalogCoordinator] --> CatDelegate

' Catalog Feature Internal Flows (Strict Clean Architecture via Use Case)
[CatalogContainerView] --> [CatalogCoordinator]
[ProductListView] --> [CatalogViewModel]
[ProductDetailView] --> [CatalogCoordinator]
[CatalogViewModel] --> FetchUseCaseProto
[CatalogViewModel] --> [CatalogCoordinator]
[FetchProductsUseCase] ..|> FetchUseCaseProto
[FetchProductsUseCase] --> ProdRepoProto
[ProductRepository] ..|> ProdRepoProto
[ProductRepository] --> [ProductEndpoint]
[ProductRepository] --> NetProto

' Checkout Feature Internal Flows (Strict Clean Architecture via Use Cases)
[CheckoutContainerView] --> [CheckoutCoordinator]
[CheckoutInputView] --> [CheckoutInputViewModel]
[DiscountView] --> [DiscountViewModel]
[PaymentView] --> [PaymentViewModel]
[CheckoutInputViewModel] ..> CoordProto
[CheckoutInputViewModel] --> OrderRepoProto
[DiscountViewModel] ..> CoordProto
[DiscountViewModel] --> CalcDiscountProto
[PaymentViewModel] ..> CoordProto
[PaymentViewModel] --> ProcessPayProto
[CalculateDiscountUseCase] ..|> CalcDiscountProto
[ProcessPaymentUseCase] ..|> ProcessPayProto
[ProcessPaymentUseCase] --> OrderRepoProto
[CheckoutCoordinator] ..|> CoordProto
[OrderRepository] ..|> OrderRepoProto
[OrderRepository] --> [CheckoutEndpoint]
[OrderRepository] --> NetProto

' Core Infrastructure Conformance
[CheckoutEndpoint] ..|> [APIEndpoint]
[ProductEndpoint] ..|> [APIEndpoint]
[URLSessionNetworkService] ..|> NetProto
[AppCoordinator] --> [NavigationRouter]
[CatalogCoordinator] --> [NavigationRouter]
[CheckoutCoordinator] --> [NavigationRouter]

@enduml
```

---

## 2. Detailed Class & Protocol UML Diagram

### PlantUML Diagram
```plantuml
@startuml ClassDiagram
skinparam classAttributeIconSize 0
skinparam class {
    BackgroundColor White
    ArrowColor #2C3E50
    BorderColor #2C3E50
}

package "App / Root Level" {
    class AppContainerView << View >> {
        -appCoordinator: AppCoordinator
    }

    interface Coordinator {
        +childCoordinators: [Coordinator]
        +start()
        +addChild(coordinator: Coordinator)
        +removeChild(coordinator: Coordinator)
    }

    class AppCoordinator << MainActor >> {
        +router: NavigationRouter
        +catalogCoordinator: CatalogCoordinator
        +checkoutCoordinator: CheckoutCoordinator
        +selectedTab: Tab
        +start()
        +catalogDidSelectProductForCheckout(Product)
    }

    class NavigationRouter << MainActor >> {
        +path: NavigationPath
        +push(route: T)
        +pop()
        +popToRoot()
    }
}

package "Core Networking Infrastructure" {
    interface APIEndpoint {
        +baseURL: URL
        +path: String
        +method: HTTPMethod
        +headers: [String: String]?
        +queryItems: [URLQueryItem]?
        +body: Data?
        +urlRequest(): URLRequest
    }

    interface NetworkServiceProtocol {
        +request(endpoint: APIEndpoint): T
        +requestData(endpoint: APIEndpoint): Data
    }

    class URLSessionNetworkService {
        -session: URLSession
        +request(endpoint: APIEndpoint): T
        +requestData(endpoint: APIEndpoint): Data
    }
}

package "Catalog Feature (Module 1)" {
    class CatalogContainerView << View >> {
        -coordinator: CatalogCoordinator
        -router: NavigationRouter
    }

    interface CatalogCoordinatorDelegate {
        +catalogDidSelectProductForCheckout(Product)
    }

    interface CatalogCoordinatorProtocol {
        +showProductDetail(Product)
        +proceedToCheckout(with: Product)
    }

    class CatalogCoordinator << MainActor >> {
        +router: NavigationRouter
        +delegate: CatalogCoordinatorDelegate?
        -fetchProductsUseCase: FetchProductsUseCaseProtocol
        +showProductDetail(Product)
        +proceedToCheckout(with: Product)
        +buildView(for: CatalogRoute): View
    }

    enum CatalogRoute {
        productList
        productDetail(Product)
    }

    class CatalogViewModel << MainActor >> {
        +products: [Product]
        +isLoading: Bool
        +errorMessage: String?
        -coordinator: CatalogCoordinatorProtocol
        -fetchProductsUseCase: FetchProductsUseCaseProtocol
        +loadProducts() async
        +selectProduct(Product)
    }

    interface ProductRepositoryProtocol {
        +fetchProducts(): [Product]
        +fetchProductDetails(id: Int): Product
    }

    interface FetchProductsUseCaseProtocol {
        +execute(): [Product]
    }

    class FetchProductsUseCase {
        -repository: ProductRepositoryProtocol
        +execute(): [Product]
    }

    class ProductRepository {
        -networkService: NetworkServiceProtocol
        +fetchProducts(): [Product]
        +fetchProductDetails(id: Int): Product
    }

    enum ProductEndpoint {
        getProducts
        getProductDetails(id: Int)
    }

    class Product << Entity >> {
        +id: Int
        +title: String
        +description: String
        +category: String
        +price: Decimal
        +rating: Double
        +thumbnail: String
    }

    class ProductDTO << Codable >> {
        +id: Int
        +title: String
        +price: Double
        +rating: Double
        +thumbnail: String
        +toDomain(): Product
    }
}

package "Checkout Feature (Module 2)" {
    class CheckoutContainerView << View >> {
        -coordinator: CheckoutCoordinator
        -router: NavigationRouter
    }

    interface CheckoutCoordinatorProtocol {
        +showDiscount(for: Order)
        +showPayment(for: Order, discount: Discount?)
        +showSuccess(result: PaymentResult)
        +finishCheckout()
    }

    class CheckoutCoordinator << MainActor >> {
        +router: NavigationRouter
        -repository: OrderRepositoryProtocol
        -calculateDiscountUseCase: CalculateDiscountUseCaseProtocol
        -processPaymentUseCase: ProcessPaymentUseCaseProtocol
        +showDiscount(for: Order)
        +showPayment(for: Order, discount: Discount?)
        +showSuccess(result: PaymentResult)
        +finishCheckout()
        +buildView(for: CheckoutRoute): View
    }

    enum CheckoutRoute {
        inputOrder
        discount(Order)
        payment(Order, Discount?)
        success(PaymentResult)
    }

    class CheckoutInputViewModel << MainActor >> {
        +itemName: String
        +itemPriceText: String
        +quantity: Int
        +isLoadingCart: Bool
        -coordinator: CheckoutCoordinatorProtocol
        -repository: OrderRepositoryProtocol
        +fetchDummyCart(id: Int) async
        +proceedToDiscount()
    }

    class DiscountViewModel << MainActor >> {
        +order: Order
        +promoCodeInput: String
        +appliedDiscount: Discount?
        -coordinator: CheckoutCoordinatorProtocol
        -calculateDiscountUseCase: CalculateDiscountUseCaseProtocol
        +applyPromoCode()
        +skipOrProceedToPayment()
    }

    class PaymentViewModel << MainActor >> {
        +order: Order
        +discount: Discount?
        +finalAmount: Decimal
        -coordinator: CheckoutCoordinatorProtocol
        -processPaymentUseCase: ProcessPaymentUseCaseProtocol
        +processPayment() async
    }

    interface OrderRepositoryProtocol {
        +fetchCart(id: Int): Order
        +submitOrder(order: Order): Order
        +processPayment(orderId: UUID, amount: Decimal): PaymentResult
    }

    interface CalculateDiscountUseCaseProtocol {
        +execute(subtotal: Decimal, promoCode: String): Discount
    }

    interface ProcessPaymentUseCaseProtocol {
        +execute(orderId: UUID, amount: Decimal): PaymentResult
    }

    class CalculateDiscountUseCase {
        +execute(subtotal: Decimal, promoCode: String): Discount
    }

    class ProcessPaymentUseCase {
        -repository: OrderRepositoryProtocol
        +execute(orderId: UUID, amount: Decimal): PaymentResult
    }

    class OrderRepository {
        -networkService: NetworkServiceProtocol
        +fetchCart(id: Int): Order
        +submitOrder(order: Order): Order
        +processPayment(orderId: UUID, amount: Decimal): PaymentResult
    }

    enum CheckoutEndpoint {
        getCart(id: Int)
        getCarts
        addCart(userId: Int, products)
        processPayment(UUID, Decimal)
    }

    class Order << Entity >> {
        +id: UUID
        +items: [Item]
        +subtotal: Decimal
    }

    class Discount << Entity >> {
        +code: String
        +percentage: Decimal
        +amountSaved: Decimal
        +finalAmount: Decimal
    }

    class PaymentResult << Entity >> {
        +transactionId: String
        +orderId: UUID
        +totalPaid: Decimal
        +status: Status
    }

    class DummyCartDTO << Codable >> {
        +id: Int
        +products: [DummyCartProductDTO]
        +total: Double
        +toDomain(): Order
    }
}

' Root & Navigation Conformance
AppContainerView --> AppCoordinator
Coordinator <|.. AppCoordinator
Coordinator <|.. CatalogCoordinator
Coordinator <|.. CheckoutCoordinator

AppCoordinator ..|> CatalogCoordinatorDelegate
AppCoordinator --> CatalogCoordinator
AppCoordinator --> CheckoutCoordinator
AppCoordinator --> NavigationRouter
CatalogCoordinator --> CatalogCoordinatorDelegate
CatalogCoordinator ..|> CatalogCoordinatorProtocol
CheckoutCoordinator ..|> CheckoutCoordinatorProtocol

' Catalog Module Relationships
CatalogContainerView --> CatalogCoordinator
CatalogCoordinator --> NavigationRouter
CatalogCoordinator --> CatalogRoute
CatalogCoordinator --> FetchProductsUseCaseProtocol
CatalogViewModel --> CatalogCoordinatorProtocol
CatalogViewModel --> FetchProductsUseCaseProtocol

FetchProductsUseCaseProtocol <|.. FetchProductsUseCase
FetchProductsUseCase --> ProductRepositoryProtocol
ProductRepositoryProtocol <|.. ProductRepository
ProductRepository --> ProductEndpoint
ProductRepository --> ProductDTO
ProductRepository --> NetworkServiceProtocol
ProductEndpoint ..|> APIEndpoint

' Checkout Module Relationships
CheckoutContainerView --> CheckoutCoordinator
CheckoutCoordinator --> NavigationRouter
CheckoutCoordinator --> CheckoutRoute
CheckoutCoordinator --> OrderRepositoryProtocol
CheckoutCoordinator --> CalculateDiscountUseCaseProtocol
CheckoutCoordinator --> ProcessPaymentUseCaseProtocol

CheckoutInputViewModel --> CheckoutCoordinatorProtocol
CheckoutInputViewModel --> OrderRepositoryProtocol
DiscountViewModel --> CheckoutCoordinatorProtocol
DiscountViewModel --> CalculateDiscountUseCaseProtocol
PaymentViewModel --> CheckoutCoordinatorProtocol
PaymentViewModel --> ProcessPaymentUseCaseProtocol

CalculateDiscountUseCaseProtocol <|.. CalculateDiscountUseCase
ProcessPaymentUseCaseProtocol <|.. ProcessPaymentUseCase
ProcessPaymentUseCase --> OrderRepositoryProtocol

OrderRepositoryProtocol <|.. OrderRepository
OrderRepository --> CheckoutEndpoint
OrderRepository --> DummyCartDTO
OrderRepository --> NetworkServiceProtocol
CheckoutEndpoint ..|> APIEndpoint

' Infrastructure
NetworkServiceProtocol <|.. URLSessionNetworkService
URLSessionNetworkService --> APIEndpoint

@enduml
```

---

## 3. End-to-End Multi-Feature Sequence Diagram

### PlantUML Diagram
```plantuml
@startuml SequenceDiagram
autonumber
actor User
participant AppContainerView as AppView
participant ProductListView as CatView
participant CatalogViewModel as CatVM
participant ProductRepository as ProdRepo
participant CatalogCoordinator as CatCoord
participant AppCoordinator as AppCoord
participant CheckoutCoordinator as CheckCoord
participant NavigationRouter as Router
participant DiscountViewModel as DiscVM
participant CalculateDiscountUseCase as DiscUseCase
participant PaymentViewModel as PayVM
participant ProcessPaymentUseCase as PayUseCase
participant OrderRepository as OrderRepo

== Feature 1: Catalog Browsing ==
User -> AppView: Launches App
AppView -> CatView: Renders initial Catalog tab
CatView -> CatVM: task { loadProducts() }
activate CatVM
CatVM -> ProdRepo: fetchProducts()
activate ProdRepo
ProdRepo --> CatVM: Returns [Product] from DummyJSON
deactivate ProdRepo
CatVM --> CatView: Updates UI with product cards (titles, prices, ratings)
deactivate CatVM

User -> CatView: Taps product (e.g. "Annibale Colombo Bed")
CatView -> CatVM: selectProduct(product)
activate CatVM
CatVM -> CatCoord: showProductDetail(product)
deactivate CatVM
activate CatCoord
CatCoord -> Router: push(CatalogRoute.productDetail(product))
Router --> User: Displays ProductDetailView with image, price & description
deactivate CatCoord

== Cross-Feature Navigation (Delegate Contract) ==
User -> CatView: Taps "Add to Cart & Checkout"
CatView -> CatCoord: proceedToCheckout(with: product)
activate CatCoord
CatCoord -> AppCoord: catalogDidSelectProductForCheckout(product) [CatalogCoordinatorDelegate]
deactivate CatCoord
activate AppCoord
AppCoord -> AppCoord: Convert Product -> Domain Order(items, subtotal)
AppCoord -> CheckCoord: showDiscount(for: order)
deactivate AppCoord
activate CheckCoord
CheckCoord -> Router: push(CheckoutRoute.discount(order))
Router --> User: Displays DiscountView (Checkout Feature)
deactivate CheckCoord

== Feature 2: Checkout User Journey ==
User -> DiscVM: Enters promo code "SAVE20" & Taps "Apply"
activate DiscVM
DiscVM -> DiscUseCase: execute(subtotal, promoCode: "SAVE20")
activate DiscUseCase
DiscUseCase --> DiscVM: Returns Discount(code: "SAVE20", amountSaved: 20%, finalAmount)
deactivate DiscUseCase
DiscVM --> User: Updates UI with discount & updated total
deactivate DiscVM

User -> DiscVM: Taps "Proceed to Payment"
activate DiscVM
DiscVM -> CheckCoord: showPayment(for: order, discount: discount)
deactivate DiscVM
activate CheckCoord
CheckCoord -> Router: push(CheckoutRoute.payment(order, discount))
Router --> User: Displays PaymentView
deactivate CheckCoord

User -> PayVM: Taps "Confirm & Pay Now"
activate PayVM
PayVM -> PayUseCase: execute(orderId, amount)
activate PayUseCase
PayUseCase -> OrderRepo: processPayment(orderId, amount)
activate OrderRepo
OrderRepo --> PayUseCase: Returns PaymentResult(transactionId: "TXN-1234", status: .success)
deactivate OrderRepo
PayUseCase --> PayVM: Returns PaymentResult
deactivate PayUseCase
PayVM -> CheckCoord: showSuccess(result: result)
deactivate PayVM
activate CheckCoord
CheckCoord -> Router: push(CheckoutRoute.success(result))
Router --> User: Displays Receipt View
deactivate CheckCoord

User -> CheckCoord: Taps "Done"
activate CheckCoord
CheckCoord -> Router: popToRoot()
Router --> User: Navigation resets to root view
deactivate CheckCoord

@enduml
```
