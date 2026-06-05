import Foundation

protocol JobRepositoryProtocol: Sendable {
    func fetchJobs() async throws -> [Job]
}

struct JobRepository: JobRepositoryProtocol {
    private let networkClient: NetworkClient
    private let fallbackLoader: FallbackJobLoaderProtocol
    private let endpoint: URL

    init(
        networkClient: NetworkClient,
        fallbackLoader: FallbackJobLoaderProtocol,
        endpoint: URL = JobEndpoints.liveJobsURL
    ) {
        self.networkClient = networkClient
        self.fallbackLoader = fallbackLoader
        self.endpoint = endpoint
    }

    func fetchJobs() async throws -> [Job] {
        do {
            return try await loadJobs(from: endpoint)
        } catch {
            let fallback = try await fallbackLoader.loadJobs()
            guard !fallback.isEmpty else { throw error }
            return fallback
        }
    }

    private func loadJobs(from url: URL) async throws -> [Job] {
        let data = try await networkClient.data(from: url)
        let response = try JSONDecoder().decode(RemotiveJobsResponse.self, from: data)
        let jobs = response.jobs.map { $0.toDomain() }
        guard !jobs.isEmpty else { throw JobRepositoryError.emptyResult }
        return jobs.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }
}

enum JobRepositoryError: LocalizedError, Equatable {
    case emptyResult

    var errorDescription: String? {
        switch self {
        case .emptyResult:
            return "No jobs are available right now."
        }
    }
}

protocol FallbackJobLoaderProtocol: Sendable {
    func loadJobs() async throws -> [Job]
}

/// Fetches fallback jobs from a remote URL (e.g. hosted `jobs_fallback.json`).
struct URLFallbackJobLoader: FallbackJobLoaderProtocol {
    private let networkClient: NetworkClient
    private let url: URL

    init(networkClient: NetworkClient, url: URL = JobEndpoints.effectiveFallbackJobsURL) {
        self.networkClient = networkClient
        self.url = url
    }

    func loadJobs() async throws -> [Job] {
        let data = try await networkClient.data(from: url)
        let response = try JSONDecoder().decode(RemotiveJobsResponse.self, from: data)
        let jobs = response.jobs.map { $0.toDomain() }
        guard !jobs.isEmpty else { throw JobRepositoryError.emptyResult }
        return jobs
    }
}

/// Loads `jobs_fallback.json` from the app bundle when no network URL is available.
struct BundleFallbackJobLoader: FallbackJobLoaderProtocol {
    private let bundle: Bundle
    private let resourceName: String

    init(bundle: Bundle = .main, resourceName: String = "jobs_fallback") {
        self.bundle = bundle
        self.resourceName = resourceName
    }

    func loadJobs() async throws -> [Job] {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw JobRepositoryError.emptyResult
        }
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(RemotiveJobsResponse.self, from: data)
        let jobs = response.jobs.map { $0.toDomain() }
        guard !jobs.isEmpty else { throw JobRepositoryError.emptyResult }
        return jobs
    }
}

/// Tries a fallback URL first, then the bundled `jobs_fallback.json`.
struct CompositeFallbackJobLoader: FallbackJobLoaderProtocol {
    private let urlLoader: URLFallbackJobLoader
    private let bundleLoader: BundleFallbackJobLoader

    init(networkClient: NetworkClient, fallbackURL: URL = JobEndpoints.effectiveFallbackJobsURL) {
        urlLoader = URLFallbackJobLoader(networkClient: networkClient, url: fallbackURL)
        bundleLoader = BundleFallbackJobLoader()
    }

    func loadJobs() async throws -> [Job] {
        do {
            return try await urlLoader.loadJobs()
        } catch {
            return try await bundleLoader.loadJobs()
        }
    }
}
