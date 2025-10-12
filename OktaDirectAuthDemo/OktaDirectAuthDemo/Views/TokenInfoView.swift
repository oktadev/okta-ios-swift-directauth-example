import SwiftUI
import AuthFoundation

/// Displays detailed information about the tokens stored in the current
/// `Credential.default` instance. This view is useful for debugging and
/// validating your DirectAuth flow -- confirming that tokens are correctly
/// issued, stored, and refreshed.
///
/// ⚠️ **Important:** Avoid showing full token strings in production apps.
/// Tokens should be treated as sensitive secrets.
struct TokenInfoView: View {
    
    /// Retrieves the current credential object managed by `AuthFoundation`.
    /// If the user is signed in, this will contain their access, ID, and refresh tokens.
    private var credential: Credential? { Credential.default }
    
    /// Used to dismiss the current view when the close button is tapped.
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Close Button
                // Dismisses the token info view when tapped.
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .foregroundStyle(.black)
                        .frame(width: 40, height: 40)
                        .padding(.leading, 10)
                }
                
                // MARK: - Token Display
                // Displays the token information as formatted monospaced text.
                // If no credential is available, a "No token found" message is shown.
                Text(credential?.toString() ?? "No token found")
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Token Info")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Credential Display Helper

extension Credential {
    /// Returns a formatted string representation of the stored token values.
    /// Includes access, ID, and refresh tokens as well as their associated scopes.
    ///
    /// - Returns: A multi-line string suitable for debugging and display in `TokenInfoView`.
    func toString() -> String {
        var result = ""

        result.append("Token type: \(token.tokenType)")
        result.append("\n\n")

        result.append("Access Token: \(token.accessToken)")
        result.append("\n\n")

        result.append("Scopes: \(token.scope?.joined(separator: ",") ?? "No scopes found")")
        result.append("\n\n")

        if let idToken = token.idToken {
            result.append("ID Token: \(idToken.rawValue)")
            result.append("\n\n")
        }

        if let refreshToken = token.refreshToken {
            result.append("Refresh Token: \(refreshToken)")
            result.append("\n\n")
        }

        return result
    }
}
