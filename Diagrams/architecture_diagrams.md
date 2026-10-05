# MVVM-C Architecture - Dependency & Interaction Diagrams

This document contains visual diagrams (both **Mermaid** for native Markdown rendering and **PlantUML** for extension previews) illustrating the structural dependencies, protocol abstractions, and runtime navigation flow of the **MVVM-C (Model-View-ViewModel-Coordinator)** architecture implementation in `MVVMC-Blueprint`.

---

## 1. High-Level Clean Architecture Layer Dependency

The rule of Clean Architecture: **Outer layers depend inward on abstract interfaces; inner domain layers have ZERO knowledge of UI, frameworks, or data persistence.**

### Mermaid Diagram
```mermaid
graph TD
    subgraph UI ["UI Layer (SwiftUI)"]
        Container["CheckoutContainerView"]
        InputView["CheckoutInputView"]
        DiscountView["DiscountView"]
        PaymentView["PaymentView"]
    end

    subgraph Presentation ["Presentation & Navigation Layer"]
        Router["NavigationRouter (@MainActor)"]
        Coordinator["CheckoutCoordinator"]
        InputVM["CheckoutInputViewModel"]
        DiscountVM["DiscountViewModel"]
        PaymentVM["PaymentViewModel"]
    end

    subgraph Domain ["Domain Layer (Pure Business Logic & Protocols)"]
        OrderRepoProtocol["OrderRepositoryProtocol"]
        CalcUseCase["CalculateDiscountUseCaseProtocol"]
        PayUseCase["ProcessPaymentUseCaseProtocol"]
        OrderModel["Order / Discount / PaymentResult Models"]
    end

    subgraph Data ["Data Layer (Adapters & DTOs)"]
        OrderRepoImpl["OrderRepository"]
        CheckoutEndpoint["CheckoutEndpoint (dummyjson.com)"]
        DummyCartDTO["DummyCartDTO"]
        OrderDTO["OrderDTO"]
    end

    subgraph Core ["Core Infrastructure Layer"]
        NetProto["NetworkServiceProtocol"]
        URLSessionEngine["URLSessionNetworkService"]
        APIEndpoint["APIEndpoint"]
    end

    %% UI -> Presentation & Navigation
    Container --> Router
    Container --> Coordinator
    InputView --> InputVM
    DiscountView --> DiscountVM
    PaymentView --> PaymentVM

    %% Presentation -> Coordinator Protocols & Domain
    Coordinator -.-> Router
    InputVM -.->|Delegate/Protocol| CoordinatorProtocol["CheckoutCoordinatorProtocol"]
    InputVM --> OrderRepoProtocol
    DiscountVM -.->|Delegate/Protocol| CoordinatorProtocol
    PaymentVM -.->|Delegate/Protocol| CoordinatorProtocol

    DiscountVM --> CalcUseCase
    PaymentVM --> PayUseCase

    %% Domain -> Data Protocol Boundary (Dependency Inversion)
    PayUseCase --> OrderRepoProtocol
    OrderRepoImpl ..|> OrderRepoProtocol
    OrderRepoImpl --> CheckoutEndpoint
    OrderRepoImpl --> NetProto
    OrderRepoImpl --> DummyCartDTO
    OrderRepoImpl --> OrderDTO
    CheckoutEndpoint ..|> APIEndpoint
    DummyCartDTO ..> OrderModel

    URLSessionEngine ..|> NetProto
    URLSessionEngine --> APIEndpoint
```

### PlantUML Diagram
```plantuml
@startuml LayerDependencies
skinparam packageBackgroundColor #F8F9FA
skinparam packageBorderColor #4A90E2

package "UI Layer (SwiftUI)" #EBF3FB {
    [CheckoutContainerView]
    [CheckoutInputView]
    [DiscountView]
    [PaymentView]
}

package "Presentation & Navigation Layer" #F3E9F8 {
    [NavigationRouter]
    [CheckoutCoordinator]
    [CheckoutCoordinatorProtocol] as CoordProto
    [CheckoutInputViewModel]
    [DiscountViewModel]
    [PaymentViewModel]
}

package "Domain Layer (Pure Business Logic & Protocols)" #E8F8F5 {
    [OrderRepositoryProtocol] as RepoProto
    [CalculateDiscountUseCaseProtocol] as CalcUseCaseProto
    [ProcessPaymentUseCaseProtocol] as PayUseCaseProto
    [CalculateDiscountUseCase]
    [ProcessPaymentUseCase]
    [Order Model] as Order
    [Discount Model] as Discount
    [PaymentResult Model] as PaymentResult
}

package "Data Layer (Adapters & DTOs)" #FEF9E7 {
    [OrderRepository]
    [CheckoutEndpoint]
    [DummyCartDTO]
    [OrderDTO]
}

package "Core / Infrastructure Layer" #F5EEF8 {
    [NetworkServiceProtocol] as NetProto
    [URLSessionNetworkService]
    [APIEndpoint]
}

' Relationships
[CheckoutContainerView] --> [NavigationRouter]
[CheckoutContainerView] --> [CheckoutCoordinator]
[CheckoutInputView] --> [CheckoutInputViewModel]
[DiscountView] --> [DiscountViewModel]
[PaymentView] --> [PaymentViewModel]

[CheckoutInputViewModel] ..> CoordProto
[CheckoutInputViewModel] --> RepoProto
[DiscountViewModel] ..> CoordProto
[PaymentViewModel] ..> CoordProto

[CheckoutCoordinator] ..|> CoordProto
[CheckoutCoordinator] --> [NavigationRouter]

[DiscountViewModel] --> CalcUseCaseProto
[PaymentViewModel] --> PayUseCaseProto

[CalculateDiscountUseCase] ..|> CalcUseCaseProto
[ProcessPaymentUseCase] ..|> PayUseCaseProto
[ProcessPaymentUseCase] --> RepoProto

[OrderRepository] ..|> RepoProto
[OrderRepository] --> [CheckoutEndpoint]
[OrderRepository] --> NetProto
[OrderRepository] --> [DummyCartDTO]
[OrderRepository] --> [OrderDTO]
[CheckoutEndpoint] ..|> [APIEndpoint]
[DummyCartDTO] ..> Order

[URLSessionNetworkService] ..|> NetProto
[URLSessionNetworkService] --> [APIEndpoint]

@enduml
```

---

## 2. Detailed Class & Protocol Diagram (UML)

This diagram details protocol decoupling, weak delegation, and dependency injection across all components. Notice that **`OrderRepositoryProtocol` is owned by Domain**, returning pure `Order` Domain Models rather than DTOs.

### PlantUML Diagram
```plantuml
@startuml ClassDiagram
skinparam classAttributeIconSize 0
skinparam class {
    BackgroundColor White
    ArrowColor #2C3E50
    BorderColor #2C3E50
}

package "Core Navigation" {
    interface Coordinator {
        +childCoordinators: [Coordinator]
        +start()
        +addChild(coordinator: Coordinator)
        +removeChild(coordinator: Coordinator)
    }

    class NavigationRouter << MainActor >> {
        +path: NavigationPath
        +push(route: T)
        +pop()
        +popToRoot()
    }

    interface CheckoutCoordinatorProtocol {
        +showDiscount(for order: Order)
        +showPayment(for order: Order, discount: Discount?)
        +showSuccess(result: PaymentResult)
        +finishCheckout()
    }

    class CheckoutCoordinator << MainActor >> {
        +router: NavigationRouter
        -repository: OrderRepositoryProtocol
        -calculateDiscountUseCase: CalculateDiscountUseCaseProtocol
        -processPaymentUseCase: ProcessPaymentUseCaseProtocol
        +buildView(for route: CheckoutRoute): View
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

package "ViewModels" {
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
}

package "Domain Layer (Pure Business Logic & Interfaces)" {
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
}

package "Data Layer (Implementation & Adapters)" {
    class OrderRepository {
        -networkService: NetworkServiceProtocol
        +fetchCart(id: Int): Order
        +submitOrder(order: Order): Order
        +processPayment(orderId: UUID, amount: Decimal): PaymentResult
    }

    class CheckoutEndpoint {
        +getCart(id: Int)
        +getCarts
        +addCart(userId: Int, products)
        +processPayment(UUID, Decimal)
    }

    class DummyCartDTO {
        +id: Int
        +products: [DummyCartProductDTO]
        +total: Double
        +discountedTotal: Double
        +userId: Int
        +toDomain(): Order
    }

    class OrderDTO {
        +orderId: String
        +totalAmount: Double
        +status: String
        +createdAt: String
        +toDomain(): Order
    }
}

' Relationships & Invocations (Declared outside packages to prevent visual duplication)
Coordinator <|.. CheckoutCoordinator
CheckoutCoordinatorProtocol <|.. CheckoutCoordinator
CheckoutCoordinator --> NavigationRouter

NetworkServiceProtocol <|.. URLSessionNetworkService
URLSessionNetworkService --> APIEndpoint

CheckoutInputViewModel --> CheckoutCoordinatorProtocol
CheckoutInputViewModel --> OrderRepositoryProtocol
DiscountViewModel --> CheckoutCoordinatorProtocol
PaymentViewModel --> CheckoutCoordinatorProtocol

CalculateDiscountUseCaseProtocol <|.. CalculateDiscountUseCase
ProcessPaymentUseCaseProtocol <|.. ProcessPaymentUseCase
DiscountViewModel --> CalculateDiscountUseCaseProtocol
PaymentViewModel --> ProcessPaymentUseCaseProtocol
ProcessPaymentUseCase --> OrderRepositoryProtocol

OrderRepositoryProtocol <|.. OrderRepository
APIEndpoint <|.. CheckoutEndpoint
OrderRepository --> NetworkServiceProtocol
OrderRepository --> CheckoutEndpoint
OrderRepository --> DummyCartDTO
OrderRepository --> OrderDTO

@enduml
```

---

## 3. Runtime Sequence Diagram

### PlantUML Diagram
```plantuml
@startuml SequenceDiagram
autonumber
actor User
participant CheckoutInputView as View
participant CheckoutInputViewModel as VM
participant OrderRepository as Repo
participant NetworkService as NetService
participant CheckoutCoordinator as Coord
participant NavigationRouter as Router
participant DiscountViewModel as DiscVM
participant CalculateDiscountUseCase as UseCase
participant PaymentViewModel as PayVM
participant ProcessPaymentUseCase as PayUseCase

alt Option A: Fetch Live Sample Cart from DummyJSON API
    User -> View: Taps "Fetch Sample Cart (dummyjson.com/carts/1)"
    View -> VM: fetchDummyCart(id: 1)
    activate VM
    VM -> Repo: fetchCart(id: 1)
    activate Repo
    Repo -> NetService: request(CheckoutEndpoint.getCart(id: 1))
    activate NetService
    NetService --> Repo: Returns DummyCartDTO (products: Blue Frock, iPhone 6, etc.)
    deactivate NetService
    Repo --> VM: Returns mapped Domain Order
    deactivate Repo
    VM -> Coord: showDiscount(for: order)
    deactivate VM
else Option B: Manual Input Order Creation
    User -> View: Enters Item Name & Price, Taps "Continue"
    View -> VM: proceedToDiscount()
    activate VM
    VM -> VM: Validate inputs & create Order
    VM -> Coord: showDiscount(for: order)
    deactivate VM
end

activate Coord
Coord -> Router: push(.discount(order))
Router --> User: Displays DiscountView with items list & total
deactivate Coord

User -> DiscVM: Enters promo code "SAVE20" & Taps "Apply"
activate DiscVM
DiscVM -> UseCase: execute(subtotal, promoCode: "SAVE20")
activate UseCase
UseCase --> DiscVM: Returns Discount(code: "SAVE20", amountSaved, finalAmount)
deactivate UseCase
DiscVM --> User: Updates UI with discount
deactivate DiscVM

User -> DiscVM: Taps "Proceed to Payment"
activate DiscVM
DiscVM -> Coord: showPayment(for: order, discount: discount)
deactivate DiscVM
activate Coord
Coord -> Router: push(.payment(order, discount))
Router --> User: Displays PaymentView
deactivate Coord

User -> PayVM: Taps "Confirm & Pay Now"
activate PayVM
PayVM -> PayUseCase: execute(orderId, amount)
activate PayUseCase
PayUseCase -> Repo: processPayment(orderId, amount)
activate Repo
Repo -> NetService: request(CheckoutEndpoint.processPayment)
activate NetService
NetService --> Repo: Returns HTTP 200 / Payment response
deactivate NetService
Repo --> PayUseCase: Returns PaymentResult(txnId: "TXN-1234", status: .success)
deactivate Repo
PayUseCase --> PayVM: Returns PaymentResult
deactivate PayUseCase
PayVM -> Coord: showSuccess(result: result)
deactivate PayVM
activate Coord
Coord -> Router: push(.success(result))
Router --> User: Displays Receipt View
deactivate Coord

User -> Coord: Taps "Done"
activate Coord
Coord -> Router: popToRoot()
Router --> User: Resets to Checkout Input View
deactivate Coord

@enduml
```
