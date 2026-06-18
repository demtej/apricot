import SwiftUI

struct EditAddressSheet: View {
    let address: String

    @EnvironmentObject private var profileStore: WalletProfileStore
    @Environment(\.dismiss) private var dismiss

    @State private var label: String = ""
    @State private var selectedColorHex: String = kDefaultWalletProfileColorHex
    @State private var previousColorHex: String = kDefaultWalletProfileColorHex
    @State private var wipeProgress: CGFloat = 1.0
    @State private var notes: String = ""

    private static let paletteHex: [String] = [
        "F4A26B", // apricot
        "D85A30", // coral
        "EF9F27", // amber
        "639922", // green
        "1D9E75", // teal
        "378ADD", // blue
        "D4537E", // pink
        "7F77DD", // purple
    ]

    private let notesLimit = 280

    var body: some View {
        NavigationStack {
            ZStack {
                Color.apricotBgPage.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        headerCard
                        sectionLabel("ALIAS")
                        aliasField
                        sectionLabel("COLOR")
                        colorPicker
                        sectionLabel("NOTES")
                        notesField
                        charCount
                    }
                    .padding(.bottom, ApricotSpacing.s10)
                }
            }
            .navigationTitle("Edit address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.apricotFgSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.apricotAccent)
                        .disabled(label.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear { loadProfile() }
    }

    // MARK: - Subviews

    private var avatarBadgeText: String {
        let compact = label.filter { !$0.isWhitespace }.uppercased()
        return String(compact.prefix(3))
    }

    private var headerCard: some View {
        HStack(spacing: ApricotSpacing.s3) {
            GeometryReader { geo in
                ZStack {
                    Circle().fill(Color(profileHex: previousColorHex))
                    Circle()
                        .fill(Color(profileHex: selectedColorHex))
                        .mask(alignment: .leading) {
                            Rectangle()
                                .frame(width: geo.size.width * wipeProgress)
                        }
                }
                .overlay(
                    Text(avatarBadgeText)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                )
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(label.isEmpty ? "No alias" : label)
                    .font(.apricotBody)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.apricotFgPrimary)
                Text(address)
                    .font(.apricotMonoSm)
                    .foregroundStyle(Color.apricotFgSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(ApricotSpacing.s4)
        .background(Color.apricotBgSurface2, in: RoundedRectangle(cornerRadius: ApricotRadius.lg))
        .padding(.horizontal, ApricotSpacing.s5)
        .padding(.top, ApricotSpacing.s4)
        .animation(.easeInOut(duration: 0.15), value: label)
    }

    private var aliasField: some View {
        TextField("Alias", text: $label)
            .font(.apricotBody)
            .foregroundStyle(Color.apricotFgPrimary)
            .padding(ApricotSpacing.s4)
            .background(Color.apricotBgElevated, in: RoundedRectangle(cornerRadius: ApricotRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: ApricotRadius.md)
                    .strokeBorder(Color.apricotBorderSubtle, lineWidth: 1)
            )
            .padding(.horizontal, ApricotSpacing.s5)
    }

    private var colorPicker: some View {
        HStack(spacing: 0) {
            ForEach(Self.paletteHex, id: \.self) { hex in
                let isSelected = hex == selectedColorHex
                Circle()
                    .fill(Color(profileHex: hex))
                    .frame(width: 34, height: 34)
                    .overlay {
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .overlay {
                        if isSelected {
                            Circle()
                                .strokeBorder(Color(profileHex: hex), lineWidth: 2.5)
                                .padding(-4)
                        }
                    }
                    .onTapGesture { selectColor(hex) }
                if hex != Self.paletteHex.last {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, ApricotSpacing.s5)
        .padding(.top, ApricotSpacing.s2)
    }

    private var notesField: some View {
        TextEditor(text: $notes)
            .font(.apricotBody)
            .foregroundStyle(Color.apricotFgPrimary)
            .scrollContentBackground(.hidden)
            .frame(minHeight: 100)
            .padding(ApricotSpacing.s3)
            .background(Color.apricotBgElevated, in: RoundedRectangle(cornerRadius: ApricotRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: ApricotRadius.md)
                    .strokeBorder(Color.apricotBorderSubtle, lineWidth: 1)
            )
            .padding(.horizontal, ApricotSpacing.s5)
            .onChange(of: notes) { _, newValue in
                if newValue.count > notesLimit {
                    notes = String(newValue.prefix(notesLimit))
                }
            }
    }

    private var charCount: some View {
        Text("\(notes.count) / \(notesLimit)")
            .font(.apricotCaption)
            .foregroundStyle(Color.apricotFgMuted)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, ApricotSpacing.s5)
            .padding(.top, ApricotSpacing.s1)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.apricotLabel)
            .tracking(.apricotTrackingWide)
            .foregroundStyle(Color.apricotFgMuted)
            .padding(.horizontal, ApricotSpacing.s5)
            .padding(.top, ApricotSpacing.s5)
            .padding(.bottom, ApricotSpacing.s2)
    }

    // MARK: - Actions

    private func loadProfile() {
        guard let profile = profileStore.profile(for: address) else { return }
        label = profile.label
        selectedColorHex = profile.colorHex
        previousColorHex = profile.colorHex
        wipeProgress = 1.0
        notes = profile.notes
    }

    private func selectColor(_ hex: String) {
        guard hex != selectedColorHex else { return }
        previousColorHex = selectedColorHex
        wipeProgress = 0
        selectedColorHex = hex
        withAnimation(.easeInOut(duration: 0.35)) {
            wipeProgress = 1.0
        }
    }

    private func save() {
        let trimmed = label.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        profileStore.rename(address: address, to: trimmed)
        profileStore.recolor(address: address, to: selectedColorHex)
        profileStore.setNotes(address: address, to: notes)
        dismiss()
    }
}

#if DEBUG
extension EditAddressSheet {
    /// Bypasses `.onAppear` profile loading — use in snapshots and previews
    /// to set the displayed state directly without touching SwiftData.
    init(address: String, label: String, colorHex: String, notes: String) {
        self.address = address
        _label = State(initialValue: label)
        _selectedColorHex = State(initialValue: colorHex)
        _previousColorHex = State(initialValue: colorHex)
        _wipeProgress = State(initialValue: 1.0)
        _notes = State(initialValue: notes)
    }
}
#endif

// MARK: - Previews

private let kPreviewAddress = "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz"

#Preview("Default (auto-label)") {
    EditAddressSheet(
        address: kPreviewAddress,
        label: "S1",
        colorHex: kDefaultWalletProfileColorHex,
        notes: ""
    )
    .environmentObject(WalletProfileStore.preview())
}

#Preview("Custom alias + teal") {
    EditAddressSheet(
        address: kPreviewAddress,
        label: "Savings",
        colorHex: "1D9E75",
        notes: "Cold storage — moved here after the April rebalance."
    )
    .environmentObject(WalletProfileStore.preview())
}

#Preview("Alias with spaces (ALR)") {
    EditAddressSheet(
        address: kPreviewAddress,
        label: "AL RIO",
        colorHex: "D4537E",
        notes: ""
    )
    .environmentObject(WalletProfileStore.preview())
}
