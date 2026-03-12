import SwiftUI

struct DomainsTabView: View {
    let domains: [ReservedDomain]
    let isLoading: Bool

    var body: some View {
        Group {
            if isLoading && domains.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if domains.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "globe")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No reserved domains")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(domains) { domain in
                            DomainCardView(domain: domain)
                        }
                    }
                    .padding(12)
                }
            }
        }
    }
}

struct DomainCardView: View {
    let domain: ReservedDomain
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "globe")
                    .foregroundStyle(.blue)
                    .font(.caption)
                Text(domain.domain)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(1)
                Spacer()
                Button(action: copyDomain) {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .font(.caption)
                        .foregroundStyle(copied ? .green : .primary)
                }
                .buttonStyle(.plain)
                .help("Copy domain")
            }

            HStack(spacing: 12) {
                if let desc = domain.description, !desc.isEmpty {
                    Text(desc)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                if let cname = domain.cnameTarget {
                    Label(cname, systemImage: "arrow.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(10)
        .background(Color.primary.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
        )
        .cornerRadius(8)
    }

    private func copyDomain() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(domain.domain, forType: .string)
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            copied = false
        }
    }
}
