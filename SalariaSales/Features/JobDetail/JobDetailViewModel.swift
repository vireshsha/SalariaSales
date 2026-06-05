import Foundation

@MainActor
final class JobDetailViewModel: ObservableObject {
    let job: Job

    var companySummary: String {
        [
            job.companyName,
            job.category,
            job.jobType
        ]
        .filter { !$0.isEmpty }
        .joined(separator: " · ")
    }

    init(job: Job) {
        self.job = job
    }
}
