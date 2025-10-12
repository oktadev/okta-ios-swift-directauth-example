import SwiftUI
import AuthFoundation

/// A view that displays the authenticated user's profile information
/// retrieved from Okta's **UserInfo** endpoint.
///
/// The `UserInfo` object is provided by **AuthFoundation** and contains
/// standard OpenID Connect (OIDC) claims such as `name`, `preferred_username`,
/// and `sub` (subject identifier). This view is shown after the user has
/// successfully authenticated, allowing you to confirm that your access token
/// can retrieve user data.
struct UserInfoView: View {
    
    /// The user information returned by the Okta UserInfo endpoint.
    let userInfo: UserInfo
    
    /// Used to dismiss the view when the close button is tapped.
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Close Button
                // Dismisses the full-screen user info view.
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .foregroundStyle(.black)
                        .frame(width: 40, height: 40)
                        .padding(.leading, 10)
                }
                
                // MARK: - User Information Text
                // Displays formatted user claims (name, username, subject, etc.)
                Text(formattedData)
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("User Info")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Data Formatting
    
    /// Builds a simple multi-line string of readable user information.
    /// Extracts common OIDC claims and formats them for display.
    private var formattedData: String {
        var result = ""
        
        // User's full name
        result.append("Name: " + (userInfo.name ?? "No name set"))
        result.append("\n\n")
        
        // Preferred username (email or login identifier)
        result.append("Username: " + (userInfo.preferredUsername ?? "No username set"))
        result.append("\n\n")
        
        // Subject identifier (unique Okta user ID)
        result.append("User ID: " + (userInfo.subject ?? "No ID found"))
        result.append("\n\n")

        // Last updated timestamp (if available)
        if let updatedAt = userInfo.updatedAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let formattedDate = dateFormatter.string(for: updatedAt)
            result.append("Updated at: " + (formattedDate ?? ""))
        }

        return result
    }
}
