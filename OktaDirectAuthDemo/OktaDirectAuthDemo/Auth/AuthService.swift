import AuthFoundation
import OktaDirectAuth
import Observation
import Foundation

protocol AuthServicing {
    // The accessToken of the logged in user
    var accessToken: String? { get }
    
    // State for driving SwiftUI
    var state: AuthService.State { get }
    
    // Sign in (Password + Okta Verify Push)
    func signIn(username: String, password: String) async throws
    
    // Sign out & revoke tokens
    func signOut() async
    
    // Refresh access token if possible (returns updated token if refreshed)
    func refreshTokenIfNeeded() async throws
    
    // Getting the userInfo out of the Credential
    func userInfo() async throws -> UserInfo?
}

@Observable
final class AuthService: AuthServicing {
    enum State: Equatable {
        case idle
        case authenticating
        case waitingForPush
        case authorized(Token)
        case failed(errorMessage: String)
    }
    
    private(set) var state: State = .idle
    @ObservationIgnored private let flow: DirectAuthenticationFlow?
    
    var accessToken: String? {
        switch state {
        case .authorized(let token):
            return token.accessToken
        default:
            return nil
        }
    }
    
    // MARK: Init
    init() {
        // Prefer PropertyListConfiguration if Okta.plist exists; otherwise fall back
        if let configuration = try? OAuth2Client.PropertyListConfiguration() {
            self.flow = try? DirectAuthenticationFlow(client: OAuth2Client(configuration))
        } else {
            self.flow = try? DirectAuthenticationFlow()
        }
        
        if let token = Credential.default?.token {
            state = .authorized(token)
        }
    }
    
    // MARK: AuthServicing
    
    func signIn(username: String, password: String) {
        Task {
            state = .authenticating
            do {
                let result = try await flow?.start(username, with: .password(password))
                
                switch result {
                case .success(let token):
                    let newCred = try Credential.store(token)
                    Credential.default = newCred
                    state = .authorized(token)
                    
                case .mfaRequired:
                    state = .waitingForPush
                    let status = try await flow?.resume(with: .oob(channel: .push))
                    if case let .success(token) = status {
                        Credential.default = try Credential.store(token)
                        state = .authorized(token)
                    }
                default:
                    break
                }
            } catch {
                state = .failed(errorMessage: error.localizedDescription)
            }
        }
    }
    
    func signOut() async {
        if let credential = Credential.default {
            try? await credential.revoke()
        }
        Credential.default = nil
        state = .idle
    }
    
    func refreshTokenIfNeeded() async throws {
        guard let credential = Credential.default else { return }
        try await credential.refresh()
    }
    
    func userInfo() async throws -> UserInfo? {
        if let userInfo = Credential.default?.userInfo {
            return userInfo
        } else {
            do {
                guard let userInfo = try await Credential.default?.userInfo() else {
                    return nil
                }
                return userInfo
            } catch {
                return nil
            }
        }
    }
}
