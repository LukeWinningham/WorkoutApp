//
//  SwiftUIView.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/6/24.

import AuthenticationServices
import SwiftUI
import Combine
import CloudKit

class AuthViewModel: ObservableObject {
    @Published var isUserAuthenticated = UserDefaults.standard.bool(forKey: "isUserSignedIn") {
        didSet {
            UserDefaults.standard.set(isUserAuthenticated, forKey: "isUserSignedIn")
            if !isUserAuthenticated {
                isProfileCompleted = false
                UserDefaults.standard.removeObject(forKey: "userIdentifier") // Remove userIdentifier when not authenticated
            }
        }
    }
    @Published var isProfileCompleted = UserDefaults.standard.bool(forKey: "isProfileCompleted") {
        didSet {
            UserDefaults.standard.set(isProfileCompleted, forKey: "isProfileCompleted")
        }
    }
    var userIdentifier: String?

    init() {
        self.userIdentifier = UserDefaults.standard.string(forKey: "userIdentifier") // Retrieve userIdentifier on init
        if isUserAuthenticated {
            checkProfileCompletion()
        }
    }

    func signIn(userIdentifier: String) {
        UserDefaults.standard.set(userIdentifier, forKey: "userIdentifier") // Save userIdentifier on sign in
        self.isUserAuthenticated = true
        self.userIdentifier = userIdentifier
        checkProfileCompletion()
    }

    func signOut() {
        self.isUserAuthenticated = false
        self.userIdentifier = nil
        UserDefaults.standard.removeObject(forKey: "userIdentifier") // Clear userIdentifier on sign out
    }

    func completeProfile() {
        self.isProfileCompleted = true
    }
    func checkProfileCompletion() {
        guard let userIdentifier = self.userIdentifier, isUserAuthenticated else { return }

        let container = CKContainer.default()
        let database = container.publicCloudDatabase
        let predicate = NSPredicate(format: "userIdentifier == %@", userIdentifier)
        let query = CKQuery(recordType: "PersonalData", predicate: predicate)

        database.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 1) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let (records, _)):
                    self.isProfileCompleted = !records.isEmpty
                case .failure(let error):
                    print("Failed to check profile completion: \(error)")
                    self.isProfileCompleted = false
                }
            }
        }
    }
}


final class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    var authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            authViewModel.signIn(userIdentifier: userIdentifier)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Authorization failed: \(error.localizedDescription)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first else {
            fatalError("Unable to find a window scene for ASAuthorizationController")
        }
        return window
    }
}

struct SignInWithAppleButtonView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result in
                switch result {
                case .success(let authorization):
                    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                        let userIdentifier = appleIDCredential.user
                        authViewModel.signIn(userIdentifier: userIdentifier)
                    }
                case .failure(let error):
                    print("Authorization failed: \(error.localizedDescription)")
                }
            }
        )
        .frame(height: 45)
        .signInWithAppleButtonStyle(.black)
    }
}

struct LogOn: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.067, green: 0.69, blue: 0.951), Color(hue: 1.0, saturation: 0.251, brightness: 0.675)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            VStack {
                if authViewModel.isUserAuthenticated {
                    if !authViewModel.isProfileCompleted {
                        PersonalData().environmentObject(authViewModel)
                    } else {
                        NavBar()
                    }
                } else {
                    SignInWithAppleButtonView()
                        .environmentObject(authViewModel)
                        .frame(width: 280, height: 45)
                }
            }
        }
    }
}

struct LogOn_Previews: PreviewProvider {
    static var previews: some View {
        LogOn().environmentObject(AuthViewModel())
    }
}

