import Foundation

@MainActor
final class AddressSearchViewModel: ObservableObject {
    @Published private(set) var state: AddressSearchState = .idle
    @Published var addressInput: String = ""

    private let service: BitcoinServiceProtocol
    private var searchTask: Task<Void, Never>?

    init(service: BitcoinServiceProtocol = LiveBitcoinService()) {
        self.service = service
    }

    // Sets state to .loading synchronously, then starts the async fetch.
    func search() {
        let trimmed = addressInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        searchTask?.cancel()
        state = .loading
        searchTask = Task { [weak self] in
            await self?.doFetch(address: trimmed)
        }
    }

    func clear() {
        searchTask?.cancel()
        addressInput = ""
        state = .idle
    }

    // MARK: - Private

    private func doFetch(address: String) async {
        do {
            let data = try await service.fetchAddressData(address: address)
            guard !Task.isCancelled else { return }
            if data.transactions.isEmpty {
                state = .empty(summary: data.summary)
            } else {
                state = .loaded(summary: data.summary, transactions: data.transactions)
            }
        } catch {
            guard !Task.isCancelled else { return }
            state = .failed((error as? AddressSearchError) ?? .unknown)
        }
    }
}
