import Foundation

@MainActor
final class TransactionDetailViewModel: ObservableObject {
    @Published private(set) var state: TransactionDetailState = .idle

    private let service: BitcoinServiceProtocol
    private var loadTask: Task<Void, Never>?

    init(service: BitcoinServiceProtocol = LiveBitcoinService()) {
        self.service = service
    }

    func load(txId: String, forAddress: String) {
        loadTask?.cancel()
        state = .loading
        loadTask = Task { [weak self] in
            await self?.doLoad(txId: txId, forAddress: forAddress)
        }
    }

    func retry(txId: String, forAddress: String) {
        load(txId: txId, forAddress: forAddress)
    }

    // MARK: - Private

    private func doLoad(txId: String, forAddress: String) async {
        do {
            let item = try await service.fetchTransactionDetail(txId: txId, forAddress: forAddress)
            guard !Task.isCancelled else { return }
            state = .loaded(item)
        } catch {
            guard !Task.isCancelled else { return }
            state = .failed((error as? TransactionDetailError) ?? .unknown)
        }
    }
}
