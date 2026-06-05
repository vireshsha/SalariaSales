import XCTest
@testable import SalariaSales

final class JobRepositoryTests: XCTestCase {
    func testFetchJobsDecodesNetworkResponse() async throws {
        let repository = JobRepository(
            networkClient: MockNetworkClient(result: .success(TestFixtures.remotiveJSON)),
            fallbackLoader: MockFallbackLoader(jobs: [], error: JobRepositoryError.emptyResult)
        )

        let jobs = try await repository.fetchJobs()
        XCTAssertEqual(jobs.count, 1)
        XCTAssertEqual(jobs.first?.title, "Mobile Developer")
        XCTAssertEqual(jobs.first?.companyName, "Acme Corp")
    }

    func testFetchJobsUsesFallbackWhenNetworkFails() async throws {
        let repository = JobRepository(
            networkClient: MockNetworkClient(result: .failure(NetworkError.invalidResponse)),
            fallbackLoader: MockFallbackLoader(jobs: [TestFixtures.sampleJob], error: nil)
        )

        let jobs = try await repository.fetchJobs()
        XCTAssertEqual(jobs, [TestFixtures.sampleJob])
    }

    func testFetchJobsThrowsWhenNetworkAndFallbackFail() async {
        let repository = JobRepository(
            networkClient: MockNetworkClient(result: .failure(NetworkError.httpStatus(500))),
            fallbackLoader: MockFallbackLoader(jobs: [], error: JobRepositoryError.emptyResult)
        )

        do {
            _ = try await repository.fetchJobs()
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }

    func testFetchJobsThrowsWhenResponseHasNoJobs() async {
        let emptyJSON = Data("{\"jobs\":[]}".utf8)
        let repository = JobRepository(
            networkClient: MockNetworkClient(result: .success(emptyJSON)),
            fallbackLoader: MockFallbackLoader(jobs: [], error: JobRepositoryError.emptyResult)
        )

        do {
            _ = try await repository.fetchJobs()
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? JobRepositoryError, .emptyResult)
        }
    }
}
