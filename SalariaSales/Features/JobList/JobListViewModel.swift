import Foundation

enum JobListScreenState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case error(String)
}

@MainActor
final class JobListViewModel: ObservableObject {
    @Published private(set) var allJobs: [Job] = []
    @Published private(set) var screenState: JobListScreenState = .idle
    @Published var searchText: String = ""

    private let repository: JobRepositoryProtocol

    var displayedJobs: [Job] {
        JobSearchFilter.filter(allJobs, query: searchText)
    }

    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(repository: JobRepositoryProtocol) {
        self.repository = repository
    }

    func loadJobs() async {
        guard screenState != .loading else { return }
        screenState = .loading

        do {
            let jobs = try await repository.fetchJobs()
            allJobs = jobs
            updateScreenStateAfterLoad()
        } catch {
            allJobs = []
            screenState = .error(error.localizedDescription)
        }
    }

    func retry() async {
        await loadJobs()
    }

    func onSearchTextChanged() {
        guard screenState == .loaded || screenState == .empty else { return }
        updateScreenStateAfterLoad()
    }

    private func updateScreenStateAfterLoad() {
        if allJobs.isEmpty {
            screenState = .empty
        } else if displayedJobs.isEmpty && isSearching {
            screenState = .empty
        } else {
            screenState = .loaded
        }
    }
}
