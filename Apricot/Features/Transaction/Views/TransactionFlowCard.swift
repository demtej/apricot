import SwiftUI

/// At most this many nodes are shown per side before the "Show N more" button appears.
private let kMaxVisibleNodes = 3
/// Beyond this threshold per side, swap to a compact count-only layout.
private let kComplexThreshold = 9

struct TransactionFlowCard: View {
    let inputs: [IOItem]
    let outputs: [IOItem]
    let feeSats: String
    var showsRealAddress: Bool = false
    var resolveAlias: ((String) -> String?)? = nil
    var onInspect: (() -> Void)? = nil

    @State private var showAllInputs = false
    @State private var showAllOutputs = false

    // Entrance animation (fires once on first appear)
    @State private var inputsVisible = false
    @State private var arrowProgress: CGFloat = 0
    @State private var outputsVisible = false

    var body: some View {
        ApricotCard {
            VStack(alignment: .leading, spacing: ApricotSpacing.s3) {
                HStack {
                    sectionLabel("FLOW")
                    Spacer()
                    if let onInspect {
                        Button(action: onInspect) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.apricotAccent)
                        }
                    }
                }
                if isComplex {
                    complexSummary
                } else {
                    flowDiagram
                }
                feeRow
            }
        }
    }

    // MARK: - Layout selection

    private var isComplex: Bool {
        inputs.count > kComplexThreshold || outputs.count > kComplexThreshold
    }

    // MARK: - Full flow diagram

    private var flowDiagram: some View {
        HStack(alignment: .top, spacing: ApricotSpacing.s2) {
            inputsColumn
                .opacity(inputsVisible ? 1 : 0)
            centerConnector
                .mask(
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            Rectangle().frame(width: arrowProgress * geo.size.width)
                            Spacer(minLength: 0)
                        }
                    }
                )
            outputsColumn
                .opacity(outputsVisible ? 1 : 0)
        }
        .task {
            guard !inputsVisible else { return }
            withAnimation(.easeOut(duration: 0.35)) { inputsVisible = true }
            try? await Task.sleep(nanoseconds: 300_000_000)
            withAnimation(.easeInOut(duration: 0.5)) { arrowProgress = 1 }
            try? await Task.sleep(nanoseconds: 520_000_000)
            withAnimation(.easeOut(duration: 0.35)) { outputsVisible = true }
        }
    }

    // MARK: - Inputs column

    private var visibleInputs: [IOItem] {
        showAllInputs ? inputs : Array(inputs.prefix(kMaxVisibleNodes))
    }

    private var hiddenInputCount: Int {
        max(0, inputs.count - kMaxVisibleNodes)
    }

    private var inputsColumn: some View {
        VStack(alignment: .leading, spacing: ApricotSpacing.s2) {
            columnHeader("FROM", count: inputs.count)
            ForEach(visibleInputs) { item in
                flowNode(item)
            }
            if !showAllInputs, hiddenInputCount > 0 {
                expandButton(hidden: hiddenInputCount) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showAllInputs = true
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Outputs column

    private var visibleOutputs: [IOItem] {
        showAllOutputs ? outputs : Array(outputs.prefix(kMaxVisibleNodes))
    }

    private var hiddenOutputCount: Int {
        max(0, outputs.count - kMaxVisibleNodes)
    }

    private var outputsColumn: some View {
        VStack(alignment: .leading, spacing: ApricotSpacing.s2) {
            columnHeader("TO", count: outputs.count)
            ForEach(visibleOutputs) { item in
                flowNode(item)
            }
            if !showAllOutputs, hiddenOutputCount > 0 {
                expandButton(hidden: hiddenOutputCount) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showAllOutputs = true
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Center connector (gradient arrow)

    private var centerConnector: some View {
        ZStack {
            HStack(spacing: 0) {
                LinearGradient(
                    colors: [Color.Apricot.scale200, Color.Apricot.scale400],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1.5)
                Image(systemName: "arrowtriangle.right.fill")
                    .font(.system(size: 6))
                    .foregroundStyle(Color.Apricot.scale400)
            }
        }
        .frame(width: 44)
        .frame(maxHeight: .infinity)
    }

    // MARK: - Complex summary fallback

    private var complexSummary: some View {
        HStack(spacing: ApricotSpacing.s3) {
            countChip(value: inputs.count, label: "inputs")
            HStack(spacing: 0) {
                LinearGradient(
                    colors: [Color.Apricot.scale200, Color.Apricot.scale400],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1.5)
                Image(systemName: "arrowtriangle.right.fill")
                    .font(.system(size: 7))
                    .foregroundStyle(Color.Apricot.scale400)
            }
            .frame(maxWidth: .infinity)
            countChip(value: outputs.count, label: "outputs")
        }
    }

    private func countChip(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.apricotTitle)
                .foregroundStyle(Color.apricotFgPrimary)
                .monospacedDigit()
            Text(label)
                .font(.apricotLabel)
                .foregroundStyle(Color.apricotFgSecondary)
        }
        .padding(.vertical, ApricotSpacing.s3)
        .frame(width: 80)
        .background(Color.apricotBgSurface2)
        .clipShape(RoundedRectangle(cornerRadius: ApricotRadius.md))
    }

    // MARK: - Fee row

    private var feeRow: some View {
        VStack(spacing: ApricotSpacing.s3) {
            Divider()
                .overlay(Color.apricotBorderSubtle)
            HStack {
                Text("Network fee")
                    .font(.apricotCaption)
                    .foregroundStyle(Color.apricotFgSecondary)
                Spacer()
                Text(feeSats)
                    .apricotMono(.small)
                    .foregroundStyle(Color.apricotFgMuted)
            }
        }
    }

    // MARK: - Node card

    private func flowNode(_ item: IOItem) -> some View {
        let displayText: String? = item.address.map { address in
            if !showsRealAddress, let alias = resolveAlias?(address) {
                return alias
            }
            return address
        }

        return VStack(alignment: .leading, spacing: 2) {
            if let text = displayText {
                Text(text)
                    .apricotMono(.small)
                    .foregroundStyle(
                        item.isRelevantAddress
                            ? Color.apricotFgPrimary
                            : Color.apricotFgSecondary
                    )
                    .lineLimit(1)
                    .truncationMode(.middle)
            } else {
                Text("Coinbase")
                    .font(.apricotCaption)
                    .italic()
                    .foregroundStyle(Color.apricotFgMuted)
            }
            Text(item.amountBTC)
                .apricotMono(.small)
                .foregroundStyle(Color.apricotFgPrimary)
        }
        .padding(.horizontal, ApricotSpacing.s3)
        .padding(.vertical, ApricotSpacing.s2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            item.isRelevantAddress ? Color.apricotAccentSoft : Color.apricotBgSurface2
        )
        .clipShape(RoundedRectangle(cornerRadius: ApricotRadius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: ApricotRadius.sm)
                .strokeBorder(
                    item.isRelevantAddress
                        ? Color.apricotAccent.opacity(0.5)
                        : Color.clear,
                    lineWidth: 1
                )
        )
    }

    // MARK: - Shared helpers

    private func columnHeader(_ title: String, count: Int) -> some View {
        Text("\(title) (\(count))")
            .font(.apricotLabel)
            .tracking(.apricotTrackingWide)
            .foregroundStyle(Color.apricotFgSecondary)
    }

    private func expandButton(hidden: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("Show \(hidden) more")
                .font(.apricotCaption)
                .foregroundStyle(Color.apricotAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, ApricotSpacing.s2)
                .background(Color.apricotBgSurface2)
                .clipShape(RoundedRectangle(cornerRadius: ApricotRadius.sm))
        }
        .buttonStyle(.plain)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.apricotLabel)
            .tracking(.apricotTrackingWide)
            .foregroundStyle(Color.apricotFgSecondary)
    }
}

// MARK: - Preview

#Preview("Simple transaction") {
    let inputs = [
        IOItem(
            index: 0,
            address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq",
            amountBTC: "0.02850000 BTC",
            amountSats: "2,850,000 sat",
            isRelevantAddress: false
        ),
        IOItem(
            index: 1,
            address: "bc1qc7slrfxkknqcq2jevvvkdgvrt8080852dfjewc",
            amountBTC: "0.02000000 BTC",
            amountSats: "2,000,000 sat",
            isRelevantAddress: false
        )
    ]
    let outputs = [
        IOItem(
            index: 0,
            address: "bc1q59gtvv4gkq3kxs5m8lspwmd7fqkdgw6txbfnt",
            amountBTC: "0.01250000 BTC",
            amountSats: "1,250,000 sat",
            isRelevantAddress: true
        ),
        IOItem(
            index: 1,
            address: "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
            amountBTC: "0.03554600 BTC",
            amountSats: "3,554,600 sat",
            isRelevantAddress: false
        )
    ]
    return ScrollView {
        TransactionFlowCard(inputs: inputs, outputs: outputs, feeSats: "4,600 sat")
            .padding()
    }
    .background(Color.apricotBgPage)
}

#Preview("Progressive disclosure") {
    let inputs = (0 ..< 5).map { i in
        IOItem(
            index: i,
            address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf\(i)mdq",
            amountBTC: "0.01000000 BTC",
            amountSats: "1,000,000 sat",
            isRelevantAddress: i == 0
        )
    }
    let outputs = (0 ..< 4).map { i in
        IOItem(
            index: i,
            address: "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx\(i)wlh",
            amountBTC: "0.01200000 BTC",
            amountSats: "1,200,000 sat",
            isRelevantAddress: i == 1
        )
    }
    return ScrollView {
        TransactionFlowCard(inputs: inputs, outputs: outputs, feeSats: "2,100 sat")
            .padding()
    }
    .background(Color.apricotBgPage)
}

#Preview("Complex transaction") {
    let inputs = (0 ..< 12).map { i in
        IOItem(
            index: i,
            address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf\(i)mdq",
            amountBTC: "0.00500000 BTC",
            amountSats: "500,000 sat",
            isRelevantAddress: false
        )
    }
    let outputs = (0 ..< 10).map { i in
        IOItem(
            index: i,
            address: "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx\(i)wlh",
            amountBTC: "0.00600000 BTC",
            amountSats: "600,000 sat",
            isRelevantAddress: i == 2
        )
    }
    return ScrollView {
        TransactionFlowCard(inputs: inputs, outputs: outputs, feeSats: "1,800 sat")
            .padding()
    }
    .background(Color.apricotBgPage)
}
