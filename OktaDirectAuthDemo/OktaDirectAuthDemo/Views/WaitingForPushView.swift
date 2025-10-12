import SwiftUI

struct WaitingForPushView: View {
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Approve the Okta Verify push on your device.")
                .multilineTextAlignment(.center)

            Button("Cancel", action: onCancel)
        }
        .padding()
    }
}
