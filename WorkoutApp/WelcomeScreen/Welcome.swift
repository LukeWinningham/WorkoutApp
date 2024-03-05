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
    @State private var showingSearchBar = false // State to control the visibility of the search bar
    @State private var searchText = ""

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
            Spacer()
            // Use NavigationLink to navigate to the ProfileView
            Button(action: {
                showingSearchBar.toggle() // Toggle the visibility of the search bar
            }) {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundColor(Color.white)
                    .padding(.trailing, 15)
            }
            .padding()
           
            .background(Color(red: 18/255, green: 18/255, blue: 18/255))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
            
            // Custom Search Bar, shown or hidden based on `showingSearchBar` state
            if showingSearchBar {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search", text: $searchText)
                        .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .background(Color(red: 60/255, green: 60/255, blue: 60/255))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 10)
                .transition(.move(edge: .trailing)) // Add a transition for the search bar appearance
                .animation(.default, value: showingSearchBar) // Animate the transition
                
            }
        }
      
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
