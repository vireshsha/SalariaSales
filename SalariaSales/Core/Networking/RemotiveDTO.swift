import Foundation

struct RemotiveJobsResponse: Decodable, Sendable {
    let jobs: [RemotiveJobDTO]
}

struct RemotiveJobDTO: Decodable, Sendable {
    let id: Int
    let title: String
    let companyName: String
    let candidateRequiredLocation: String
    let salary: String?
    let description: String
    let companyLogo: String?
    let jobType: String
    let category: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case companyName = "company_name"
        case candidateRequiredLocation = "candidate_required_location"
        case salary
        case description
        case companyLogo = "company_logo"
        case jobType = "job_type"
        case category
        case url
    }

    func toDomain() -> Job {
        Job(
            id: id,
            title: title,
            companyName: companyName,
            location: candidateRequiredLocation,
            salaryRange: salary?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            description: HTMLTextSanitizer.plainText(from: description),
            companyLogoURL: companyLogo.flatMap(URL.init(string:)),
            jobType: jobType.replacingOccurrences(of: "_", with: " ").capitalized,
            category: category,
            applyURL: URL(string: url)
        )
    }
}
