import SwiftUI

struct EditAddressSheet: View {
    let address: String

    @EnvironmentObject private var profileStore: WalletProfileStore
    @Environment(\.dismiss) private var dismiss

    @State private var label: String = ""
    @State private var selectedColor: WalletProfileColor = .apricot
    @State private var previousColor: WalletProfileColor = .apricot
    @State private var wipeProgress: CGFloat = 1.0
    @State private var notes: String = ""
    @State private var pendingTagNames: [String] = []
    @State private var tagInput: String = ""
    @FocusState private var isTagFieldFocused: Bool
    @State private var availableTags: [Tag] = []
    @State private var skipLoad: Bool = false

    private let notesLimit = 280
    private let tagMaxLength = 30
    private let tagMaxCount = 10

    private var tagSuggestions: [Tag] {
        availableTags.filter { !pendingTagNames.contains($0.name) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.apricotBgPage.ignoresSafeArea()
                ScrollViewReader { proxy in
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
                            sectionLabel("TAGS")
                            tagsSection
                            Color.clear.frame(height: 1).id("tagBottom")
                        }
                        .padding(.bottom, ApricotSpacing.s10)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: isTagFieldFocused) { _, focused in
                        if focused {
                            // Wait for keyboard animation to finish before scrolling
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    proxy.scrollTo("tagBottom", anchor: .bottom)
                                }
                            }
                        }
                    }
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
        .onAppear { if !skipLoad { loadProfile() } }
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
                    Circle().fill(previousColor.color)
                    Circle()
                        .fill(selectedColor.color)
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
            ForEach(WalletProfileColor.allCases, id: \.self) { palette in
                let isSelected = palette == selectedColor
                Circle()
                    .fill(palette.color)
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
                                .strokeBorder(palette.color, lineWidth: 2.5)
                                .padding(-4)
                        }
                    }
                    .onTapGesture { selectColor(palette) }
                if palette != WalletProfileColor.allCases.last {
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

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: ApricotSpacing.s2) {
            if !pendingTagNames.isEmpty {
                TagFlowLayout(spacing: ApricotSpacing.s2) {
                    ForEach(pendingTagNames, id: \.self) { name in
                        TagChip(name: name) {
                            pendingTagNames.removeAll { $0 == name }
                        }
                    }
                }
                .padding(.horizontal, ApricotSpacing.s5)
            }

            if pendingTagNames.count < tagMaxCount {
                TextField("Add tag", text: $tagInput)
                    .font(.apricotBody)
                    .foregroundStyle(Color.apricotFgPrimary)
                    .padding(ApricotSpacing.s4)
                    .background(Color.apricotBgElevated, in: RoundedRectangle(cornerRadius: ApricotRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: ApricotRadius.md)
                            .strokeBorder(Color.apricotBorderSubtle, lineWidth: 1)
                    )
                    .padding(.horizontal, ApricotSpacing.s5)
                    .focused($isTagFieldFocused)
                    .onSubmit { commitTagInput() }
                    .onChange(of: tagInput) { _, new in
                        if new.contains(",") {
                            tagInput = new.replacingOccurrences(of: ",", with: "")
                            commitTagInput()
                        } else if new.count > tagMaxLength {
                            tagInput = String(new.prefix(tagMaxLength))
                        }
                    }

                let suggestions = tagSuggestions
                if !suggestions.isEmpty {
                    tagSuggestionsCarousel(suggestions)
                        .id("tagBottom")
                }
            }
        }
    }

    private func tagSuggestionsCarousel(_ suggestions: [Tag]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ApricotSpacing.s2) {
                ForEach(suggestions, id: \.name) { tag in
                    Button {
                        guard pendingTagNames.count < tagMaxCount else { return }
                        pendingTagNames.append(tag.name)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 9, weight: .bold))
                            Text(tag.name)
                                .font(.apricotCaption)
                        }
                        .foregroundStyle(Color.apricotFgSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.apricotBgSurface, in: Capsule())
                        .overlay(Capsule().strokeBorder(Color.apricotBorderSubtle, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, ApricotSpacing.s5)
            .padding(.vertical, 2)
        }
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
        availableTags = profileStore.allTags()
        guard let profile = profileStore.profile(for: address) else { return }
        label = profile.label
        selectedColor = profile.color
        previousColor = profile.color
        wipeProgress = 1.0
        notes = profile.notes
        pendingTagNames = profile.tags.sorted { $0.createdAt < $1.createdAt }.map(\.name)
    }

    private func selectColor(_ color: WalletProfileColor) {
        guard color != selectedColor else { return }
        previousColor = selectedColor
        wipeProgress = 0
        selectedColor = color
        withAnimation(.easeInOut(duration: 0.35)) {
            wipeProgress = 1.0
        }
    }

    private func commitTagInput() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespaces).uppercased()
        tagInput = ""
        guard !trimmed.isEmpty,
              trimmed.count <= tagMaxLength,
              !pendingTagNames.contains(trimmed),
              pendingTagNames.count < tagMaxCount else { return }
        pendingTagNames.append(trimmed)
        availableTags = profileStore.allTags()
    }

    private func save() {
        let trimmed = label.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        profileStore.rename(address: address, to: trimmed)
        profileStore.recolor(address: address, to: selectedColor)
        profileStore.setNotes(address: address, to: notes)

        let currentTags = profileStore.profile(for: address)?.tags ?? []
        let currentNames = Set(currentTags.map(\.name))
        let pendingSet = Set(pendingTagNames)
        for tag in currentTags where !pendingSet.contains(tag.name) {
            profileStore.removeTag(tag, from: address)
        }
        for name in pendingTagNames where !currentNames.contains(name) {
            let tag = profileStore.createTagIfNeeded(name: name)
            profileStore.addTag(tag, to: address)
        }

        dismiss()
    }
}

// MARK: - Tag chip

private struct TagChip: View {
    let name: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(name)
                .font(.apricotCaption)
                .foregroundStyle(Color.apricotFgPrimary)
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.apricotFgMuted)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.apricotBgSurface2, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.apricotBorderSubtle, lineWidth: 1))
    }
}

// MARK: - Flow layout for tag chips

private struct TagFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Preview init (bypasses onAppear)

extension EditAddressSheet {
    /// Bypasses `.onAppear` profile loading — use in snapshots and previews
    /// to set the displayed state directly without touching SwiftData.
    init(address: String, label: String, color: WalletProfileColor, notes: String, tags: [String] = []) {
        self.address = address
        _label = State(initialValue: label)
        _selectedColor = State(initialValue: color)
        _previousColor = State(initialValue: color)
        _wipeProgress = State(initialValue: 1.0)
        _notes = State(initialValue: notes)
        _pendingTagNames = State(initialValue: tags)
        _skipLoad = State(initialValue: true)
    }
}

// MARK: - Previews

private let kPreviewAddress = "bc1qar0srrr7xfkvy5l643lydnw9re59gtzz"

#Preview("Default (auto-label)") {
    EditAddressSheet(
        address: kPreviewAddress,
        label: "S1",
        color: .apricot,
        notes: ""
    )
    .environmentObject(WalletProfileStore.preview())
}

#Preview("Custom alias + teal") {
    EditAddressSheet(
        address: kPreviewAddress,
        label: "Savings",
        color: .teal,
        notes: "Cold storage — moved here after the April rebalance.",
        tags: ["cold storage", "dca"]
    )
    .environmentObject(WalletProfileStore.preview())
}

#Preview("Alias with spaces (ALR)") {
    EditAddressSheet(
        address: kPreviewAddress,
        label: "AL RIO",
        color: .pink,
        notes: ""
    )
    .environmentObject(WalletProfileStore.preview())
}
