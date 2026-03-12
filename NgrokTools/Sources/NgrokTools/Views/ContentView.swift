import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            Text("Loading...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(.secondary)
        }
        .frame(width: 380, height: 480)
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "network")
                .foregroundStyle(.blue)
            Text("ngrok Tools")
                .font(.headline)
            Spacer()
            Button(action: {}) {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
