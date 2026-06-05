import SwiftUI

struct JobListView: View {
    @StateObject private var viewModel: JobListViewModel
    private let container: AppContainer

    init(viewModel: JobListViewModel, container: AppContainer = .live) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.container = container
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.screenState {
                case .idle, .loading:
                    LoadingStateView(message: "Loading jobs…")
                case .error(let message):
                    ErrorStateView(message: message) {
                        Task { await viewModel.retry() }
                    }
                case .empty:
                    EmptyStateView(
                        title: viewModel.isSearching ? "No matching jobs" : "No jobs available",
                        message: viewModel.isSearching
                            ? "Try a different job title or company name."
                            : "Check back later for new openings."
                    )
                case .loaded:
                    jobList
                }
            }
            .navigationTitle("Jobs")
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search by title or company"
            )
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.onSearchTextChanged()
            }
            .task {
                if viewModel.screenState == .idle {
                    await viewModel.loadJobs()
                }
            }
            .refreshable {
                await viewModel.loadJobs()
            }
        }
    }

    private var jobList: some View {
        List(viewModel.displayedJobs) { job in
            NavigationLink(value: job) {
                JobRowView(job: job)
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: Job.self) { job in
            JobDetailView(viewModel: container.makeJobDetailViewModel(job: job))
        }
    }
}

#Preview {
    let container = AppContainer.preview()
    return JobListView(
        viewModel: container.makeJobListViewModel(),
        container: container
    )
}
