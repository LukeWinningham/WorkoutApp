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
    @Published var profilePicture: UIImage?

    var userIdentifier: String?

    private let container = CKContainer.default()
    var database: CKDatabase { container.publicCloudDatabase }

    init() {
        self.userIdentifier = UserDefaults.standard.string(forKey: "userIdentifier")
        if isUserAuthenticated {
            fetchUsername()
            checkProfileCompletion()
        }
    }
    func fetchProfilePicture() {
        guard let userIdentifier = self.userIdentifier else { return }

        let predicate = NSPredicate(format: "userIdentifier == %@", userIdentifier)
        let query = CKQuery(recordType: "PersonalData", predicate: predicate)

        database.perform(query, inZoneWith: nil) { [weak self] records, error in
            guard let self = self, let record = records?.first, error == nil else {
                print("Failed to fetch PersonalData record: \(String(describing: error))")
                return
            }

            if let profilePictureAsset = record["ProfilePicture"] as? CKAsset, let fileURL = profilePictureAsset.fileURL {
                if let imageData = try? Data(contentsOf: fileURL), let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.profilePicture = image
                    }
                }
            }
        }
    }
    func signIn(userIdentifier: String) {
        UserDefaults.standard.set(true, forKey: "isUserSignedIn") // Mark the user as signed in
        UserDefaults.standard.set(userIdentifier, forKey: "userIdentifier")
        self.isUserAuthenticated = true
        self.userIdentifier = userIdentifier
        fetchUsername()
        checkProfileCompletion()
    }

    func signOut() {
        UserDefaults.standard.set(false, forKey: "isUserSignedIn") // Mark the user as signed out
        UserDefaults.standard.removeObject(forKey: "userIdentifier")
        self.isUserAuthenticated = false
        self.userIdentifier = nil
        self.isProfileCompleted = false
    }


    func completeProfile() {
        UserDefaults.standard.set(true, forKey: "isProfileCompleted")
        self.isProfileCompleted = true
    }
    func saveProfilePicture(image: UIImage) {
        guard let userIdentifier = self.userIdentifier else { return }

        // Convert image to CKAsset
        guard let asset = image.toCKAsset() else { return }

        // Fetch PersonalData record for the current user
        let predicate = NSPredicate(format: "userIdentifier == %@", userIdentifier)
        let query = CKQuery(recordType: "PersonalData", predicate: predicate)

        database.perform(query, inZoneWith: nil) { [weak self] records, error in
            guard let self = self, let record = records?.first else { return }

            // Update the ProfilePicture field with the new CKAsset
            record["ProfilePicture"] = asset

            // Save the updated record
            self.database.save(record) { updatedRecord, error in
                if let error = error {
                    print("Error saving profile picture: \(error)")
                    return
                }
                print("Profile picture updated successfully")
            }
        }
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
            Color(red: 18/255, green: 18/255, blue: 18/255)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Image("Logo") // Assuming "AppIcon" is the name of your image asset
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 500, height: 500) // Adjust size as needed
                
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
