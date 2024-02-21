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
    @Published var selectedPackID: UUID?
    @Published var isUserAuthenticated = UserDefaults.standard.bool(forKey: "isUserSignedIn")
    @Published var isProfileCompleted = UserDefaults.standard.bool(forKey: "isProfileCompleted")
    @Published var username: String? // Holds the fetched username

    var userIdentifier: String?

    private let container = CKContainer.default()
    private var database: CKDatabase { container.publicCloudDatabase }

    init() {
        self.userIdentifier = UserDefaults.standard.string(forKey: "userIdentifier")
        if isUserAuthenticated {
            fetchUsername()
            checkProfileCompletion()
        }
    }

    func signIn(userIdentifier: String) {
        UserDefaults.standard.set(userIdentifier, forKey: "userIdentifier")
        self.isUserAuthenticated = true
        self.userIdentifier = userIdentifier
        fetchUsername()
        checkProfileCompletion()
    }

    func signOut() {
        self.isUserAuthenticated = false
        self.userIdentifier = nil
        UserDefaults.standard.removeObject(forKey: "userIdentifier")
    }

    func completeProfile() {
        self.isProfileCompleted = true
    }

    func fetchUsername() {
        guard let userIdentifier = self.userIdentifier else { return }

        let predicate = NSPredicate(format: "userIdentifier == %@", userIdentifier)
        let query = CKQuery(recordType: "PersonalData", predicate: predicate) // Adjust "User" to your actual record type

        database.perform(query, inZoneWith: nil) { [weak self] records, error in
            DispatchQueue.main.async {
                guard let record = records?.first else { return }
                self?.username = record["username"] as? String // Adjust "username" to your actual field name
            }
        }
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

