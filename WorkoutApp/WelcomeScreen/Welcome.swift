//
//  Welcome.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/5/24.
//

import SwiftUI
import Combine

struct Welcome: View {
    @EnvironmentObject var navigationState: NavigationState
    @EnvironmentObject var authViewModel: AuthViewModel // Access the AuthViewModel

    var body: some View {
        ZStack {
            Color(red: 18/255, green: 18/255, blue: 18/255)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 30) {
                welcomeSection
                VStack {
                    VStack {
                        Text("Welcome Back,")
                            .font(.title3)
                            .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                            .bold()
                        // Use the username from AuthViewModel
                        Text(authViewModel.username ?? "User") // Fallback to "User" if username is nil
                            .font(.system(size:50))
                            .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                            .bold()
                    }
                }
                Spacer()
                TodaysWorkout() // Assuming this is defined elsewhere
                Spacer()
                FriendActivity() // Assuming this is defined elsewhere
            }
            .onAppear {
                authViewModel.fetchProfilePicture()
            }
        }
    }
    private var welcomeSection: some View {
        HStack {
            // Use NavigationLink to navigate to the ProfileView
            NavigationLink(destination: ProfileView()) {
                if let profileImage = authViewModel.profilePicture {
                    // If there is a profile picture, display it
                    Image(uiImage: profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30.0, height: 30.0)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                } else {
                    // If there is no profile picture, display a placeholder
                    Image("placeholder") // Replace "placeholder" with your placeholder image name
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30.0, height: 30.0)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
            }
            Spacer()
        }
        .padding()
    }

}

struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        let navigationState = NavigationState()
        let authViewModel = AuthViewModel()
        NavigationView {
            Welcome()
                .environmentObject(navigationState)
                .environmentObject(authViewModel) // Provide the AuthViewModel here
        }
    }
}
