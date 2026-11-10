import Observation
import SwiftUI

/// Concrete Coordinator for managing the Checkout user journey flow.
@MainActor
@Observable
public final class CheckoutCoordinator: Coordinator, CheckoutCoordinatorProtocol {
    public var childCoordinators: [Coordinator] = []
    
    /// Router managing the SwiftUI NavigationPath
    public var router: NavigationRouter
    
    // Dependencies
    private let repository: OrderRepositoryProtocol
    private let calculateDiscountUseCase: CalculateDiscountUseCaseProtocol
    private let processPaymentUseCase: ProcessPaymentUseCaseProtocol
    
    public init(
        router: NavigationRouter,
        repository: OrderRepositoryProtocol,
        calculateDiscountUseCase: CalculateDiscountUseCaseProtocol,
        processPaymentUseCase: ProcessPaymentUseCaseProtocol? = nil
    ) {
        self.router = router
        self.repository = repository
        self.calculateDiscountUseCase = calculateDiscountUseCase
        self.processPaymentUseCase = processPaymentUseCase ?? ProcessPaymentUseCase(repository: repository)
    }
    
    public convenience init(router: NavigationRouter) {
        let repository = OrderRepository()
        self.init(
            router: router,
            repository: repository,
            calculateDiscountUseCase: CalculateDiscountUseCase(),
            processPaymentUseCase: ProcessPaymentUseCase(repository: repository)
        )
    }
    
    public convenience init() {
        let router = NavigationRouter()
        let repository = OrderRepository()
        let discountUseCase = CalculateDiscountUseCase()
        self.init(
            router: router,
            repository: repository,
            calculateDiscountUseCase: discountUseCase,
            processPaymentUseCase: ProcessPaymentUseCase(repository: repository)
        )
    }
    
    public func start() {
        // Root flow start
        router.popToRoot()
    }
    
    // MARK: - Navigation Actions
    
    public func showDiscount(for order: Order) {
        router.push(CheckoutRoute.discount(order))
    }
    
    public func showPayment(for order: Order, discount: Discount?) {
        router.push(CheckoutRoute.payment(order, discount))
    }
    
    public func showSuccess(result: PaymentResult) {
        router.push(CheckoutRoute.success(result))
    }
    
    public func finishCheckout() {
        router.popToRoot()
    }
    
    // MARK: - View Factory
    
    @ViewBuilder
    public func buildView(for route: CheckoutRoute) -> some View {
        switch route {
        case .inputOrder:
            makeCheckoutInputView()
        case .discount(let order):
            makeDiscountView(for: order)
        case .payment(let order, let discount):
            makePaymentView(for: order, discount: discount)
        case .success(let result):
            makeSuccessView(result: result)
        }
    }
    
    // MARK: - Factory Helpers
    
    private func makeCheckoutInputView() -> some View {
        let viewModel = CheckoutInputViewModel(coordinator: self)
        return CheckoutInputView(viewModel: viewModel)
    }
    
    private func makeDiscountView(for order: Order) -> some View {
        let viewModel = DiscountViewModel(
            order: order,
            coordinator: self,
            calculateDiscountUseCase: calculateDiscountUseCase
        )
        return DiscountView(viewModel: viewModel)
    }
    
    private func makePaymentView(for order: Order, discount: Discount?) -> some View {
        let viewModel = PaymentViewModel(
            order: order,
            discount: discount,
            coordinator: self,
            processPaymentUseCase: processPaymentUseCase
        )
        return PaymentView(viewModel: viewModel)
    }
    
    private func makeSuccessView(result: PaymentResult) -> some View {
        ReceiptView(result: result, onDone: finishCheckout)
    }
}
