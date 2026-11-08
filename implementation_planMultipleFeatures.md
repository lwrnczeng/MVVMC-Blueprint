# Implementation Plan - Multi-Feature Architecture & Cross-Feature Communication

This plan outlines adding a second full feature—**`Catalog` Feature**—to `MVVMC-Blueprint` under `Sources/MVVMCBlueprint/Features/Catalog`.

It demonstrates production-grade **Multi-Feature Architecture** and **Cross-Feature Communication** (Zero Direct Coupling between features), incorporating **Feature Protocol Contracts**, **AppCoordinator Root Orchestration**, and real API integration (`https://dummyjson.com/products`).

---

## Architectural Breakdown & Module Isolation

```
                             [ AppCoordinator (Root) ]
                                /                 \
  (CatalogCoordinatorDelegate) /                   \ (CheckoutCoordinatorDelegate)
                              v                     v
                 [ Catalog Feature ]           [ Checkout Feature ]
                 ├── Domain/                   ├── Domain/
                 ├── Presentation/             ├── Presentation/
                 └── Data/                     └── Data/
```

### Key Architectural Principles
1. **Decoupled Feature Contracts (`Feature Interfaces`)**:
   - `CatalogFeature` knows **nothing** about `CheckoutFeature` concrete classes or views.
   - Cross-feature transitions are declared via delegate protocols (e.g. `CatalogCoordinatorDelegate`: `func catalogDidRequestCheckout(with product: Product)`).
2. **Root Orchestration (`AppCoordinator`)**:
   - `AppCoordinator` manages top-level flow (Tab bar or Root Navigation), owns child coordinators (`CatalogCoordinator`, `CheckoutCoordinator`), and implements feature delegates to seamlessly navigate across feature boundaries.
3. **`Catalog` Feature Architecture**:
   - **Domain**: `Product` Model, `ProductRepositoryProtocol`, `FetchProductsUseCase`.
   - **Presentation**: `ProductListView`, `ProductDetailView`, `CatalogViewModel`, `CatalogCoordinator`, `CatalogRoute`.
   - **Data**: `ProductDTO`, `ProductEndpoint` (`https://dummyjson.com/products`), `ProductRepository` (with offline fallback to `Products.json`).

---

## Proposed Changes

```
Sources/MVVMCBlueprint/
├── Core/
│   └── Navigation/
│       ├── AppCoordinator.swift            // [NEW] Root Coordinator orchestrating feature flows
│       ├── Coordinator.swift               // Existing base protocol
│       └── NavigationRouter.swift
└── Features/
    ├── Catalog/                            // [NEW FEATURE]
    │   ├── Coordinators/
    │   │   ├── CatalogCoordinator.swift    // Manages Catalog navigation stack
    │   │   ├── CatalogCoordinatorDelegate.swift // Cross-feature communication protocol
    │   │   └── CatalogRoute.swift          // Hashable routes (.productList, .productDetail)
    │   ├── Domain/
    │   │   ├── Models/
    │   │   │   └── Product.swift           // Pure Domain Entity
    │   │   ├── Repositories/
    │   │   │   └── ProductRepositoryProtocol.swift // Domain Contract
    │   │   └── UseCases/
    │   │       └── FetchProductsUseCase.swift
    │   ├── Data/
    │   │   ├── DTOs/
    │   │   │   └── ProductDTO.swift        // DummyJSON Products payload mapping
    │   │   ├── Endpoints/
    │   │   │   └── ProductEndpoint.swift   // GET https://dummyjson.com/products
    │   │   └── Repositories/
    │   │       └── ProductRepository.swift
    │   ├── ViewModels/
    │   │   └── CatalogViewModel.swift
    │   └── Views/
    │       ├── ProductListView.swift
    │       └── ProductDetailView.swift
    └── Checkout/                           // Existing Feature
        └── ...
```

---

## User Review Required

> [!IMPORTANT]
> **Cross-Feature Protocol Isolation**:
> 1. **Zero Feature Cross-Importing**: `CatalogViewModel` and `CatalogCoordinator` communicate strictly via `CatalogCoordinatorDelegate`. When a user taps "Buy Now", `AppCoordinator` receives the delegate call and starts `CheckoutCoordinator` with the selected `Product`.
> 2. **DummyJSON Live Integration**: Fetches real product lists from `https://dummyjson.com/products` (laptops, smartphones, fragrances, etc.) with image thumbnails, ratings, and prices.

---

## Verification Plan

### Automated Tests
- Add `CatalogViewModelTests` and `CatalogCoordinatorTests` to `Tests/MVVMCBlueprintTests/`.
- Execute `swift test` ensuring all 15+ unit tests pass cleanly.

### Diagram Updates
- Update PlantUML and Markdown architecture documents to include `AppCoordinator`, `Catalog Feature`, and `CatalogCoordinatorDelegate`.
