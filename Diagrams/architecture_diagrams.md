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

    subgraph Data ["Data Layer (Implementations & Storage)"]
        OrderRepoImpl["OrderRepository"]
        OrderDTO["OrderDTO"]
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
    DiscountVM -.->|Delegate/Protocol| CoordinatorProtocol
    PaymentVM -.->|Delegate/Protocol| CoordinatorProtocol

    DiscountVM --> CalcUseCase
    PaymentVM --> PayUseCase

    %% Domain -> Data Protocol Boundary (Dependency Inversion)
    PayUseCase --> OrderRepoProtocol
    OrderRepoImpl ..|> OrderRepoProtocol
    OrderRepoImpl --> OrderDTO
    OrderDTO ..> OrderModel
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

package "Domain Layer (Pure Business Logic)" #E8F8F5 {
    [OrderRepositoryProtocol] as RepoProto
    [CalculateDiscountUseCaseProtocol] as CalcUseCaseProto
    [ProcessPaymentUseCaseProtocol] as PayUseCaseProto
    [CalculateDiscountUseCase]
    [ProcessPaymentUseCase]
    [Order Model] as Order
    [Discount Model] as Discount
    [PaymentResult Model] as PaymentResult
}

package "Data Layer" #FEF9E7 {
    [OrderRepository]
    [OrderDTO]
}

' Relationships
[CheckoutContainerView] --> [NavigationRouter]
[CheckoutContainerView] --> [CheckoutCoordinator]
[CheckoutInputView] --> [CheckoutInputViewModel]
[DiscountView] --> [DiscountViewModel]
[PaymentView] --> [PaymentViewModel]

[CheckoutInputViewModel] ..> CoordProto
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
[OrderRepository] --> [OrderDTO]
[OrderDTO] ..> Order

@enduml
```

---

## 2. Detailed Class & Protocol Diagram (UML)

This diagram details protocol decoupling, weak delegation, and dependency injection across all components. Notice that **`OrderRepositoryProtocol` is owned by Domain**, returning pure `Order` Domain Models rather than `OrderDTO`.

### Mermaid Diagram
```mermaid
classDiagram
    %% Core Navigation
    class Coordinator {
        <<interface>>
        +childCoordinators: [Coordinator]
        +start()
        +addChild(coordinator)
        +removeChild(coordinator)
    }

    class NavigationRouter {
        +path: NavigationPath
        +push(route)
        +pop()
        +popToRoot()
    }

    class CheckoutCoordinatorProtocol {
        <<interface>>
        +showDiscount(for: Order)
        +showPayment(for: Order, discount: Discount?)
        +showSuccess(result: PaymentResult)
        +finishCheckout()
    }

    class CheckoutCoordinator {
        +router: NavigationRouter
        -repository: OrderRepositoryProtocol
        -calculateDiscountUseCase: CalculateDiscountUseCaseProtocol
        -processPaymentUseCase: ProcessPaymentUseCaseProtocol
        +buildView(for: CheckoutRoute) View
    }

    Coordinator <|-- CheckoutCoordinator
    CheckoutCoordinatorProtocol <|.. CheckoutCoordinator
    CheckoutCoordinator --> NavigationRouter

    %% ViewModels
    class CheckoutInputViewModel {
        +itemName: String
        +itemPriceText: String
        +quantity: Int
        -coordinator: CheckoutCoordinatorProtocol?
        +proceedToDiscount()
    }

    class DiscountViewModel {
        +order: Order
        +promoCodeInput: String
        +appliedDiscount: Discount?
        -coordinator: CheckoutCoordinatorProtocol?
        -calculateDiscountUseCase: CalculateDiscountUseCaseProtocol
        +applyPromoCode()
        +skipOrProceedToPayment()
    }

    class PaymentViewModel {
        +order: Order
        +discount: Discount?
        +finalAmount: Decimal
        -coordinator: CheckoutCoordinatorProtocol?
        -processPaymentUseCase: ProcessPaymentUseCaseProtocol
        +processPayment() async
    }

    CheckoutInputViewModel --> CheckoutCoordinatorProtocol
    DiscountViewModel --> CheckoutCoordinatorProtocol
    PaymentViewModel --> CheckoutCoordinatorProtocol

    %% Domain UseCases & Repository Protocols
    class OrderRepositoryProtocol {
        <<interface>>
        +submitOrder(order: Order) async Order
        +processPayment(orderId: UUID, amount: Decimal) async PaymentResult
    }

    class CalculateDiscountUseCaseProtocol {
        <<interface>>
        +execute(subtotal: Decimal, promoCode: String) Discount
    }

    class ProcessPaymentUseCaseProtocol {
        <<interface>>
        +execute(orderId: UUID, amount: Decimal) async PaymentResult
    }

    class CalculateDiscountUseCase {
        +execute(subtotal: Decimal, promoCode: String) Discount
    }

    class ProcessPaymentUseCase {
        -repository: OrderRepositoryProtocol
        +execute(orderId: UUID, amount: Decimal) async PaymentResult
    }

    CalculateDiscountUseCaseProtocol <|.. CalculateDiscountUseCase
    ProcessPaymentUseCaseProtocol <|.. ProcessPaymentUseCase
    DiscountViewModel --> CalculateDiscountUseCaseProtocol
    PaymentViewModel --> ProcessPaymentUseCaseProtocol
    ProcessPaymentUseCase --> OrderRepositoryProtocol

    %% Data Layer Implementations
    class OrderRepository {
        +submitOrder(order: Order) async Order
        +processPayment(orderId: UUID, amount: Decimal) async PaymentResult
    }

    class OrderDTO {
        +orderId: String
        +totalAmount: Double
        +status: String
        +createdAt: String
        +toDomain() Order
    }

    OrderRepositoryProtocol <|.. OrderRepository
    OrderRepository --> OrderDTO
```

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

    Coordinator <|.. CheckoutCoordinator
    CheckoutCoordinatorProtocol <|.. CheckoutCoordinator
    CheckoutCoordinator --> NavigationRouter
}

package "ViewModels" {
    class CheckoutInputViewModel << MainActor >> {
        +itemName: String
        +itemPriceText: String
        +quantity: Int
        -coordinator: CheckoutCoordinatorProtocol
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

    CheckoutInputViewModel --> CheckoutCoordinatorProtocol
    DiscountViewModel --> CheckoutCoordinatorProtocol
    PaymentViewModel --> CheckoutCoordinatorProtocol
}

package "Domain Layer (Owns Entities & Repository Protocols)" {
    interface OrderRepositoryProtocol {
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

    CalculateDiscountUseCaseProtocol <|.. CalculateDiscountUseCase
    ProcessPaymentUseCaseProtocol <|.. ProcessPaymentUseCase
    DiscountViewModel --> CalculateDiscountUseCaseProtocol
    PaymentViewModel --> ProcessPaymentUseCaseProtocol
    ProcessPaymentUseCase --> OrderRepositoryProtocol
}

package "Data Layer (Implementation & Storage)" {
    class OrderRepository {
        +submitOrder(order: Order): Order
        +processPayment(orderId: UUID, amount: Decimal): PaymentResult
    }

    class OrderDTO {
        +orderId: String
        +totalAmount: Double
        +status: String
        +createdAt: String
        +toDomain(): Order
    }

    OrderRepositoryProtocol <|.. OrderRepository
    OrderRepository --> OrderDTO
}
@enduml
```

---

## 3. Runtime Sequence Diagram

This sequence diagram depicts what happens when a user creates an order, applies a promo code, and completes payment.

### Mermaid Diagram
```mermaid
sequenceDiagram
    autonumber
    actor User
    participant View as CheckoutInputView
    participant VM as CheckoutInputViewModel
    participant Coord as CheckoutCoordinator
    participant Router as NavigationRouter
    participant DiscVM as DiscountViewModel
    participant UseCase as CalculateDiscountUseCase
    participant PayVM as PaymentViewModel
    participant PayUseCase as ProcessPaymentUseCase
    participant Repo as OrderRepository

    User->>View: Enters Item Name & Price, Taps "Continue"
    View->>VM: proceedToDiscount()
    VM->>VM: Validates inputs & constructs Order model
    VM->>Coord: showDiscount(for: order)
    Coord->>Router: push(.discount(order))
    Router-->>User: Renders DiscountView

    User->>DiscVM: Enters promo code "SAVE20" & Taps "Apply"
    DiscVM->>UseCase: execute(subtotal: 50.0, promoCode: "SAVE20")
    UseCase-->>DiscVM: Returns Discount(code: "SAVE20", amountSaved: 10.0, finalAmount: 40.0)
    DiscVM-->>User: Updates UI showing discount

    User->>DiscVM: Taps "Proceed to Payment"
    DiscVM->>Coord: showPayment(for: order, discount: discount)
    Coord->>Router: push(.payment(order, discount))
    Router-->>User: Renders PaymentView

    User->>PayVM: Taps "Confirm & Pay Now"
    PayVM->>PayUseCase: execute(orderId, amount: 40.0)
    PayUseCase->>Repo: processPayment(orderId, amount)
    Repo-->>PayUseCase: Returns PaymentResult(txnId: "TXN-1234", status: .success)
    PayUseCase-->>PayVM: Returns PaymentResult
    PayVM->>Coord: showSuccess(result: result)
    Coord->>Router: push(.success(result))
    Router-->>User: Displays Receipt View

    User->>Coord: Taps "Done"
    Coord->>Router: popToRoot()
    Router-->>User: Returns to Checkout Input View
```

### PlantUML Diagram
```plantuml
@startuml SequenceDiagram
autonumber
actor User
participant CheckoutInputView as View
participant CheckoutInputViewModel as VM
participant CheckoutCoordinator as Coord
participant NavigationRouter as Router
participant DiscountViewModel as DiscVM
participant CalculateDiscountUseCase as UseCase
participant PaymentViewModel as PayVM
participant ProcessPaymentUseCase as PayUseCase
participant OrderRepository as Repo

User -> View: Enters Item Name & Price, Taps "Continue"
View -> VM: proceedToDiscount()
activate VM
VM -> VM: Validate inputs & create Order
VM -> Coord: showDiscount(for: order)
deactivate VM
activate Coord
Coord -> Router: push(.discount(order))
Router --> User: Displays DiscountView
deactivate Coord

User -> DiscVM: Enters promo code "SAVE20" & Taps "Apply"
activate DiscVM
DiscVM -> UseCase: execute(subtotal: 50.0, promoCode: "SAVE20")
activate UseCase
UseCase --> DiscVM: Returns Discount(code: "SAVE20", amountSaved: 10.0, finalAmount: 40.0)
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
PayVM -> PayUseCase: execute(orderId, amount: 40.0)
activate PayUseCase
PayUseCase -> Repo: processPayment(orderId, amount)
activate Repo
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
