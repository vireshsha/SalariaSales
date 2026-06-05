import SwiftUI

struct JobRowView: View {
    let job: Job

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CompanyLogoView(url: job.companyLogoURL, companyName: job.companyName)

            VStack(alignment: .leading, spacing: 6) {
                Text(job.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(job.companyName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Label(job.displayLocation, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Label(job.displaySalary, systemImage: "dollarsign.circle")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(job.title) at \(job.companyName), \(job.displayLocation), \(job.displaySalary)")
    }
}

private struct CompanyLogoView: View {
    let url: URL?
    let companyName: String

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        }
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.15))
            Text(String(companyName.prefix(1)).uppercased())
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    List {
        JobRowView(job: .previewSamples[0])
    }
}
