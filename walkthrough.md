# Walkthrough - MVVM-C Architecture Blueprint

We have created a production-ready **MVVM-C (Model-View-ViewModel-Coordinator)** baseline sample project under [MVVMC-Blueprint](file:///Users/lzeng/Documents/A_Career/CareerWorkspace/TechnicalDrilling/MVVMC-Blueprint).

---

## What Was Built

```
TechnicalDrilling/MVVMC-Blueprint/
├── Package.swift                                            // Swift Package Manifest (iOS 16+ / macOS 13+)
├── Sources/
│   └── MVVMCBlueprint/
│       ├── Core/
│       │   └── Navigation/
│       │       ├── Coordinator.swift                        // Base Coordinator protocol & Child lifecycle
│       │       └── NavigationRouter.swift                   // MainActor NavigationPath state wrapper
│       └── Features/
│           └── Checkout/
│               ├── Coordinators/
│               │   ├── CheckoutCoordinator.swift            // Concrete Coordinator & View Factory
│               │   └── CheckoutRoute.swift                  // Hashable routes enum (NavigationPath compatible)
│               ├── Views/
│               │   ├── CheckoutContainerView.swift          // Root NavigationStack container
│               │   ├── CheckoutInputView.swift              // Screen 1: Item input
│               │   ├── DiscountView.swift                   // Screen 2: Promo code entry & calculation
│               │   └── PaymentView.swift                    // Screen 3: Payment summary & action
│               ├── ViewModels/
│               │   ├── CheckoutInputViewModel.swift         // Presentation logic for screen 1
│               │   ├── DiscountViewModel.swift              // Presentation logic for screen 2
│               │   └── PaymentViewModel.swift               // Presentation logic for screen 3
│               ├── Domain/
│               │   ├── Models/
│               │   │   ├── Order.swift                      // Sendable Value Domain Model
│               │   │   ├── Discount.swift                   // Sendable Value Domain Model
│               │   │   └── PaymentResult.swift              // Sendable Value Domain Model
│               │   └── UseCases/
│               │       ├── CalculateDiscountUseCase.swift   // Pure Business Logic Protocol & Impl
│               │       └── ProcessPaymentUseCase.swift      // Pure Business Logic Protocol & Impl
│               └── Data/
│                   ├── DTOs/
│                   │   └── OrderDTO.swift                   // Data Transfer Object & Domain Mapper
│                   └── Repositories/
│                       ├── OrderRepositoryProtocol.swift    // Interface boundary
│                       └── OrderRepository.swift            // Network / DB Mock Repository
└── Tests/
    └── MVVMCBlueprintTests/
        ├── CalculateDiscountUseCaseTests.swift              // Pure Domain unit tests
        ├── CheckoutInputViewModelTests.swift                // ViewModel tests with Mock Coordinator
        └── CheckoutCoordinatorTests.swift                  // Navigation stack tests
```

---

## Architectural Highlights

### 1. The Coordinator Layer (`CheckoutCoordinator`)
- **Decoupled Views**: Views no longer hold direct navigation links to other views (`NavigationLink(destination: ...)`).
- **Decoupled ViewModels**: ViewModels delegate navigation decisions to `CheckoutCoordinatorProtocol` (e.g. `coordinator?.showDiscount(for: order)`).
- **View Factory**: The Coordinator acts as a view builder, injecting required domain UseCases and Repositories into ViewModels.

### 2. SwiftUI `NavigationStack` Integration (`NavigationRouter`)
- Manages type-safe navigation routes (`CheckoutRoute`) via `@MainActor NavigationRouter`.
- Seamlessly integrates with SwiftUI's `.navigationDestination(for: CheckoutRoute.self)`.

### 3. Pure Domain & Data Separation
- `CalculateDiscountUseCase` and `ProcessPaymentUseCase` contain zero UI logic and zero UIKit/SwiftUI imports.
- Protocols (`OrderRepositoryProtocol`, `CalculateDiscountUseCaseProtocol`, `CheckoutCoordinatorProtocol`) enable 100% isolation in Unit Testing.

---

## Verification Results

### Automated Tests Execution
Executed `swift test` in terminal. Output:

```
Build complete! (6.76s)
Test Suite 'All tests' started.
Test Suite 'CalculateDiscountUseCaseTests' passed (Executed 3 tests, 0 failures).
Test Suite 'CheckoutCoordinatorTests' passed (Executed 2 tests, 0 failures).
Test Suite 'CheckoutInputViewModelTests' passed (Executed 3 tests, 0 failures).
Total: 8 tests passed, 0 failures in 0.002 seconds.
```
