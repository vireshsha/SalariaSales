import XCTest
@testable import SalariaSales

@MainActor
final class JobListViewModelTests: XCTestCase {
    func testLoadJobsSuccessSetsLoadedState() async {
        let viewModel = JobListViewModel(
            repository: MockJobRepository(result: .success([TestFixtures.sampleJob]))
        )

        await viewModel.loadJobs()

        XCTAssertEqual(viewModel.screenState, .loaded)
        XCTAssertEqual(viewModel.allJobs.count, 1)
        XCTAssertEqual(viewModel.displayedJobs.count, 1)
    }

    func testLoadJobsFailureSetsErrorState() async {
        let viewModel = JobListViewModel(
            repository: MockJobRepository(result: .failure(NetworkError.decodingFailed))
        )

        await viewModel.loadJobs()

        if case .error(let message) = viewModel.screenState {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("Expected error state")
        }
        XCTAssertTrue(viewModel.allJobs.isEmpty)
    }

    func testSearchFiltersDisplayedJobs() async {
        let jobs = [
            TestFixtures.sampleJob,
            Job(
                id: 2,
                title: "Designer",
                companyName: "Acme Corp",
                location: "Remote",
                salaryRange: "",
                description: "",
                companyLogoURL: nil,
                jobType: "Full Time",
                category: "Design",
                applyURL: nil
            )
        ]
        let viewModel = JobListViewModel(repository: MockJobRepository(result: .success(jobs)))
        await viewModel.loadJobs()

        viewModel.searchText = "mobile"
        viewModel.onSearchTextChanged()

        XCTAssertEqual(viewModel.displayedJobs.count, 1)
        XCTAssertEqual(viewModel.displayedJobs.first?.title, "Mobile Developer")
    }

    func testSearchWithNoResultsSetsEmptyState() async {
        let viewModel = JobListViewModel(
            repository: MockJobRepository(result: .success([TestFixtures.sampleJob]))
        )
        await viewModel.loadJobs()

        viewModel.searchText = "zzzz"
        viewModel.onSearchTextChanged()

        XCTAssertEqual(viewModel.screenState, .empty)
        XCTAssertTrue(viewModel.displayedJobs.isEmpty)
    }

    func testLoadJobsWithEmptyListSetsEmptyState() async {
        let viewModel = JobListViewModel(repository: MockJobRepository(result: .success([])))
        await viewModel.loadJobs()

        XCTAssertEqual(viewModel.screenState, .empty)
    }

    func testDoesNotReloadWhileAlreadyLoading() async {
        let slowRepo = SlowJobRepository()
        let viewModel = JobListViewModel(repository: slowRepo)

        async let first: Void = viewModel.loadJobs()
        await viewModel.loadJobs()
        await first

        let fetchCount = await slowRepo.fetchCount
        XCTAssertEqual(fetchCount, 1)
    }
}

private actor SlowJobRepository: JobRepositoryProtocol {
    private(set) var fetchCount = 0

    func fetchJobs() async throws -> [Job] {
        fetchCount += 1
        try await Task.sleep(nanoseconds: 200_000_000)
        return [TestFixtures.sampleJob]
    }
}
