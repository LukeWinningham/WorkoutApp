//
//  SwiftUIView.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/6/24.

import AuthenticationServices
import SwiftUI
import Combine
class AuthViewModel: ObservableObject {
    @Published var isUserAuthenticated = false

    func signIn() {
        self.isUserAuthenticated = true
    }

    func signOut() {
        self.isUserAuthenticated = false
    }
}

final class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    var authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            print("User ID: \(userIdentifier)")
            authViewModel.signIn()
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Authorization failed: \(error.localizedDescription)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("Unable to find a window scene for ASAuthorizationController")
        }
        return window
    }
}

        
        // Coordinator definition remains the same
        
struct SignInWithAppleButtonView: View {
    @EnvironmentObject var authViewModel: AuthViewModel // Use the shared instance from the environment

    
    var body: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result in
                switch result {
                case .success(let authorization):
                    // Directly handle the authorization result here, without creating a new ASAuthorizationController
                    switch authorization.credential {
                    case let appleIDCredential as ASAuthorizationAppleIDCredential:
                        let userIdentifier = appleIDCredential.user
                        print("User ID: \(userIdentifier)")
                        // Here, call a method on your authViewModel to handle the successful sign in
                        authViewModel.signIn()
                        
                    default:
                        break
                    }
                case .failure(let error):
                    print("Authorization failed: \(error.localizedDescription)")
                    // Optionally, handle the error, e.g., by updating the UI or showing an error message
                }
            }
        )
        .frame(height: 45)
        .signInWithAppleButtonStyle(.black)
    
    }
}

struct LogOn: View {
    @EnvironmentObject var authViewModel: AuthViewModel // Use the shared instance from the environment

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.067, green: 0.69, blue: 0.951), Color(hue: 1.0, saturation: 0.251, brightness: 0.675)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            VStack {
                SignInWithAppleButtonView()
                    .environmentObject(authViewModel) // Pass the shared AuthViewModel instance
                    .frame(width: 280, height: 45)
            }
        }
    }
}



struct LogOn_Previews: PreviewProvider {
    static var previews: some View {
        LogOn()
            .environmentObject(AuthViewModel())
    }
}
