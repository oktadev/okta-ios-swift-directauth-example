import Foundation
import Observation
import AuthFoundation

/// The `AuthViewModel` acts as the bridge between your app's UI and the authentication layer (`AuthService`).
/// It coordinates user actions such as signing in, signing out, refreshing tokens, and fetching user profile data.
/// This class uses Swift's `@Observable` macro so that your SwiftUI views can automatically react to state changes.
@Observable
final class AuthViewModel {
    // MARK: - Dependencies
    
    /// The authentication service responsible for handling DirectAuth sign-in,
    /// push-based MFA, token management, and user info retrieval.
    private let authService: AuthServicing

    // MARK: - UI State Properties
    
    /// Stores the user's token, which can be used for secure communication
    /// with backend services that validate the user's identity.
    var accessToken: String?
    
    /// Represents a loading statex. Set to `true` when background operations are running
    /// (such as sign-in, sign-out, or token refresh) to display a progress indicator.
    var isLoading: Bool = false
    
    /// Holds any human-readable error messages that should be displayed in the UI
    /// (for example, invalid credentials or network errors).
    var errorMessage: String?
    
    /// The username and password properties are bound to text fields in the UI.
    /// As the user types, these values update automatically thanks to SwiftUI's reactive data binding.
    /// The view model then uses them to perform DirectAuth sign-in when the user submits the form.
    var username: String = ""
    var password: String = ""
    
    /// Exposes the current authentication state (idle, authenticating, waitingForPush, authorized, failed)
    /// as defined by the `AuthService.State` enum. The view can use this to display the correct UI.
    var state: AuthService.State {
        authService.state
    }
    
    // MARK: - Initialization

    /// Initializes the view model with a default instance of `AuthService`.
    /// You can inject a mock `AuthServicing` implementation for testing.
    init(authService: AuthServicing = AuthService()) {
        self.authService = authService
    }
    
    // MARK: - Authentication Actions
    
    /// Attempts to authenticate the user with the provided credentials.
    /// This triggers the full DirectAuth flow -- including password verification,
    /// push notification MFA (if required), and secure token storage via AuthFoundation.
    @MainActor
    func signIn() async {
        setLoading(true)
        defer { setLoading(false) }
        
        do {
            try await authService.signIn(username: username, password: password)
            accessToken = authService.accessToken
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Signs the user out by revoking active tokens, clearing local credentials,
    /// and resetting the app's authentication state.
    @MainActor
    func signOut() async {
        setLoading(true)
        defer { setLoading(false) }
        
        await authService.signOut()
    }
    
    // MARK: - Token Handling
    
    /// Refreshes the user's access token using their refresh token.
    /// This allows the app to maintain a valid session without requiring
    /// the user to log in again after the access token expires.
    @MainActor
    func refreshToken() async {
        setLoading(true)
        defer { setLoading(false) }

        do {
            try await authService.refreshTokenIfNeeded()
            accessToken = authService.accessToken
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - User Info Retrieval
    
    /// Fetches the authenticated user's profile information from Okta.
    /// Returns a `UserInfo` object containing standard OIDC claims (such as `name`, `email`, and `sub`).
    /// If fetching fails (e.g., due to expired tokens or network issues), it returns `nil`.
    @MainActor
    func fetchUserInfo() async -> UserInfo? {
        do {
            let userInfo = try await authService.userInfo()
            return userInfo
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    // MARK: - UI Helpers
    
    /// Updates the `isLoading` property. This is used to show or hide
    /// a loading spinner in your SwiftUI view while background work is in progress.
    private func setLoading(_ value: Bool) {
        isLoading = value
    }
}

