@testable import Apricot
import SwiftUI

@MainActor
final class TransactionFlowCardSnapshotTests: SnapshotTestCase {
    func test_transactionFlowCard_simple() {
        assertScreenSnapshot(
            of: makeCard(
                inputs: SnapshotFixtures.simpleInputs,
                outputs: SnapshotFixtures.simpleOutputs,
                feeSats: "1,200 sat"
            ),
            named: "simple"
        )
    }

    func test_transactionFlowCard_complexFallback() {
        assertScreenSnapshot(
            of: makeCard(
                inputs: SnapshotFixtures.complexInputs,
                outputs: SnapshotFixtures.complexOutputs,
                feeSats: "3,400 sat"
            ),
            named: "complex_fallback"
        )
    }

    private func makeCard(inputs: [IOItem], outputs: [IOItem], feeSats: String) -> some View {
        ScrollView {
            TransactionFlowCard(inputs: inputs, outputs: outputs, feeSats: feeSats)
                .padding(.horizontal, ApricotSpacing.s5)
                .padding(.vertical, ApricotSpacing.s4)
        }
        .background(Color.apricotBgPage)
    }
}
