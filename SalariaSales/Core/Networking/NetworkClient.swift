import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .httpStatus(let code):
            return "The server responded with status code \(code)."
        case .decodingFailed:
            return "Unable to read job data from the server."
        case .noData:
            return "No data was returned from the server."
        }
    }
}

protocol NetworkClient: Sendable {
    func data(from url: URL) async throws -> Data
}

struct URLSessionNetworkClient: NetworkClient {
    let session: URLSession

    func data(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200 ... 299).contains(http.statusCode) else {
            throw NetworkError.httpStatus(http.statusCode)
        }
        guard !data.isEmpty else {
            throw NetworkError.noData
        }
        return data
    }
}

struct MockNetworkClient: NetworkClient {
    var result: Result<Data, Error>

    func data(from url: URL) async throws -> Data {
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
}
