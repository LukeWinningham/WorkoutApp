//
//  Discovery.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/13/24.



import SwiftUI
import Combine

struct Discovery: View {
    @EnvironmentObject var navigationState: NavigationState
    @EnvironmentObject var authViewModel: AuthViewModel // Make sure to inject AuthViewModel
    @State private var searchText = ""
    @State private var showingSearchBar = false // State to control the visibility of the search bar

    var body: some View {
        ZStack {
            Color(red: 18/255, green: 18/255, blue: 18/255).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                HStack {
                    // Profile picture on the far left as a navigation link
                    NavigationLink(destination: ProfileView()) {
                        if let profileImage = authViewModel.profilePicture {
                            Image(uiImage: profileImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30.0, height: 30.0)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle") // Use your placeholder image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30.0, height: 30.0)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.leading, 10)

                    Text("Discover")
                        .font(.title)
                        .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                        .padding(.trailing, 25)
                        .bold()

                    Spacer()

                    // Magnifying glass icon to show/hide the search bar
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
                
                
                // Content Views
                ScrollView {
                    Trending()
                    DiscoverPacks()
                    Suggestions()
                }
                
                Spacer() // Pushes the content up
            }
            .padding(.top, 10) // You can adjust this value as needed
        }
    }
}

struct Discovery_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Discovery()
                .environmentObject(NavigationState())
                .environmentObject(AuthViewModel()) // Provide the AuthViewModel for the preview
        }
    }
}
