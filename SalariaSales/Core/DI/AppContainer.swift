import Foundation

/// Central dependency injection container for the application.
@MainActor
struct AppContainer {
    let jobRepository: JobRepositoryProtocol

    static let live = AppContainer(
        jobRepository: JobRepository(
            networkClient: URLSessionNetworkClient(session: .shared),
            fallbackLoader: CompositeFallbackJobLoader(
                networkClient: URLSessionNetworkClient(session: .shared)
            )
        )
    )

    static func preview(repository: JobRepositoryProtocol = PreviewJobRepository()) -> AppContainer {
        AppContainer(jobRepository: repository)
    }

    func makeJobListViewModel() -> JobListViewModel {
        JobListViewModel(repository: jobRepository)
    }

    func makeJobDetailViewModel(job: Job) -> JobDetailViewModel {
        JobDetailViewModel(job: job)
    }
}

/// In-memory repository for SwiftUI previews and tests.
struct PreviewJobRepository: JobRepositoryProtocol {
    func fetchJobs() async throws -> [Job] {
        Job.previewSamples
    }
}
