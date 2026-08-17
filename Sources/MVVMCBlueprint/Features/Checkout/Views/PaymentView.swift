import SwiftUI

public struct PaymentView: View {
    @ObservedObject var viewModel: PaymentViewModel
    
    public init(viewModel: PaymentViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("Total Payment Amount")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("$\(NSDecimalNumber(decimal: viewModel.finalAmount).stringValue)")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.primary)
                
                if let discount = viewModel.discount {
                    Text("Saved $\(NSDecimalNumber(decimal: discount.amountSaved).stringValue) with \(discount.code)")
                        .font(.footnote)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.05))
            .cornerRadius(12)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            Spacer()
            
            Button(action: {
                Task {
                    await viewModel.processPayment()
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 8)
                    }
                    Text(viewModel.isLoading ? "Processing..." : "Confirm & Pay Now")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isLoading ? Color.gray : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(viewModel.isLoading)
        }
        .padding()
        .navigationTitle("Review & Payment")
    }
}
