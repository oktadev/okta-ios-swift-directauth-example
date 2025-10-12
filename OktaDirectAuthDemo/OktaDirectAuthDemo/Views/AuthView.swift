import SwiftUI
import AuthFoundation

/// A simple wrapper for `UserInfo` used to present user profile data in a full-screen modal.
/// Conforms to `Identifiable` so it can be used with `.fullScreenCover(item:)`.
struct UserInfoModel: Identifiable {
    let id = UUID()
    let user: UserInfo
}

/// The main SwiftUI view for managing the authentication experience.
/// This view observes the `AuthViewModel`, displays different UI states
/// based on the current authentication flow, and provides controls for
/// signing in, signing out, refreshing tokens, and viewing user or token information.
struct AuthView: View {
    
    // MARK: - View Model
    
    /// The view model that manages all authentication logic and state transitions.
    /// It uses `@Observable` from Swift's Observation framework, so changes here
    /// automatically trigger UI updates.
    @State private var viewModel = AuthViewModel()
    
    // MARK: - State and Presentation
    
    /// Holds the currently fetched user information (if available).
    /// When this value is set, the `UserInfoView` is displayed as a full-screen sheet.
    @State private var userInfo: UserInfoModel?
    
    /// Controls whether the Token Info screen is presented as a full-screen modal.
    @State private var showTokenInfo = false
    
    // MARK: - View Body
    
    var body: some View {
        VStack {
            // Render the UI based on the current authentication state.
            // Each case corresponds to a different phase of the DirectAuth flow.
            switch viewModel.state {
            case .idle, .failed:
                loginForm
            case .authenticating:
                ProgressView("Signing in...")
            case .waitingForPush:
                // Waiting for Okta Verify push approval
                WaitingForPushView {
                    Task { await viewModel.signOut() }
                }
            case .authorized:
                successView
            }
        }
        .padding()
        // Show Token Info full screen
        .fullScreenCover(isPresented: $showTokenInfo) {
            TokenInfoView()
        }
        // Show User Info full screen
        .fullScreenCover(item: $userInfo) { info in
            UserInfoView(userInfo: info.user)
        }
    }
}

// MARK: - Login Form View
private extension AuthView {
    /// The initial sign-in form displayed when the user is not authenticated.
    /// Captures username and password input and triggers the DirectAuth sign-in flow.
    private var loginForm: some View {
        VStack(spacing: 16) {
            Text("Okta DirectAuth (Password + Okta Verify Push)")
                .font(.headline)
            
            // Email input field (bound to view model's username property)
            TextField("Email", text: $viewModel.username)
                .keyboardType(.emailAddress)
                .textContentType(.username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            // Secure password input field
            SecureField("Password", text: $viewModel.password)
                .textContentType(.password)
            
            // Triggers authentication via DirectAuth and Push MFA
            Button("Sign In") {
                Task { await viewModel.signIn() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.username.isEmpty || viewModel.password.isEmpty)
            
            // Display error message if sign-in fails
            if case .failed(let message) = viewModel.state {
                Text(message)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
        }
    }
}

// MARK: - Authorized State View
private extension AuthView {
    /// Displayed once the user has successfully signed in and completed MFA.
    /// Shows the user's ID token and provides actions for token refresh, user info,
    /// token details, and sign-out.
    private var successView: some View {
        VStack(spacing: 16) {
            Text("Signed in 🎉")
                .font(.title2)
                .bold()
            
            // Scrollable ID token display (for demo purposes)
            ScrollView {
                Text(Credential.default?.token.idToken?.rawValue ?? "(no id token)")
                    .font(.footnote)
                    .textSelection(.enabled)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(8)
            }
            .frame(maxHeight: 220)
            
            // Authenticated user actions
            tokenInfoButton
            userInfoButton
            refreshTokenButton
            signoutButton
        }
        .padding()
    }
}

// MARK: - Action Buttons
private extension AuthView {
    /// Signs the user out, revoking tokens and returning to the login form.
    var signoutButton: some View {
        Button("Sign Out") {
            Task { await viewModel.signOut() }
        }
        .font(.system(size: 14))
    }
    
    /// Opens the full-screen view showing token info.
    var tokenInfoButton: some View {
        Button("Token Info") {
            showTokenInfo = true
        }
        .disabled(viewModel.isLoading)
    }
    
    /// Loads user info and presents it full screen.
    @MainActor
    var userInfoButton: some View {
        Button("User Info") {
            Task {
                if let user = await viewModel.fetchUserInfo() {
                    userInfo = UserInfoModel(user: user)
                }
            }
        }
        .font(.system(size: 14))
        .disabled(viewModel.isLoading)
    }
    
    /// Refresh Token if needed
    var refreshTokenButton: some View {
        Button("Refresh Token") {
            Task { await viewModel.refreshToken() }
        }
        .font(.system(size: 14))
        .disabled(viewModel.isLoading)
    }
}

