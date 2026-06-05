import SwiftUI

struct JobDetailView: View {
    @ObservedObject var viewModel: JobDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                salarySection
                locationSection
                companySection
                descriptionSection
                applyButton
            }
            .padding()
        }
        .navigationTitle(viewModel.job.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.job.title)
                .font(.title2.bold())
            Text(viewModel.companySummary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var salarySection: some View {
        DetailSection(title: "Salary (INR)") {
            Label(viewModel.job.displaySalary, systemImage: "indianrupeesign.circle")
        }
    }

    private var locationSection: some View {
        DetailSection(title: "Location") {
            Label(viewModel.job.displayLocation, systemImage: "mappin.and.ellipse")
        }
    }

    private var companySection: some View {
        DetailSection(title: "Company") {
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.job.companyName)
                    .font(.body.weight(.semibold))
                Text("Category: \(viewModel.job.category)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Type: \(viewModel.job.jobType)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var descriptionSection: some View {
        DetailSection(title: "Description") {
            Text(viewModel.job.description)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var applyButton: some View {
        if let url = viewModel.job.applyURL {
            Link(destination: url) {
                Text("View on Remotive")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

private struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        JobDetailView(
            viewModel: JobDetailViewModel(job: .previewSamples[0])
        )
    }
}
