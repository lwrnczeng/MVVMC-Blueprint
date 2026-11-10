import SwiftUI

/// View displaying the payment confirmation receipt.
public struct ReceiptView: View {
    public let result: PaymentResult
    public let onDone: () -> Void

    public init(result: PaymentResult, onDone: @escaping () -> Void) {
        self.result = result
        self.onDone = onDone
    }

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("Payment Successful!")
                .font(.title)
                .bold()

            Text("Transaction ID: \(result.transactionId)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text("Total Paid:")
                Text(result.totalPaid, format: .currency(code: "USD"))
                    .bold()
            }
            .font(.headline)

            Button("Done", action: onDone)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, 20)
        }
        .padding()
        .navigationTitle("Receipt")
    }
}
