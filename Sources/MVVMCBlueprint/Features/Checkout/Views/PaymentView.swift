import SwiftUI

public struct PaymentView: View {
    @Bindable private var viewModel: PaymentViewModel
    
    public init(viewModel: PaymentViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("Total Payment Amount")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(viewModel.finalAmount, format: .currency(code: "USD"))
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                
                if let discount = viewModel.discount {
                    Text("Saved \(discount.amountSaved.formatted(.currency(code: "USD"))) with \(discount.code)")
                        .font(.footnote)
                        .foregroundStyle(.green)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.tint.opacity(0.08), in: .rect(cornerRadius: 12))
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
            
            Spacer()
            
            Button(action: submitPayment) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .padding(.trailing, 8)
                    }
                    Text(viewModel.isLoading ? "Processing..." : "Confirm & Pay Now")
                        .bold()
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(viewModel.isLoading ? .gray : .green)
            .disabled(viewModel.isLoading)
        }
        .padding()
        .navigationTitle("Review & Payment")
    }

    private func submitPayment() {
        Task {
            await viewModel.processPayment()
        }
    }
}
