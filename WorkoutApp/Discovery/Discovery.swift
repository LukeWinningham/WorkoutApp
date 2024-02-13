//
//  Discovery.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/13/24.
//
import SwiftUI
import Combine

struct Discovery: View {
    @EnvironmentObject var navigationState: NavigationState
    @State private var searchText = ""

    var body: some View {
        ZStack {
            Color(red: 18/255, green: 18/255, blue: 18/255).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Discover")
                    .font(.system(size:30))
                    .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                    .bold()
                
                // Custom Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search", text: $searchText)
                        .foregroundColor(Color.white)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .background(Color(red: 60/255, green: 60/255, blue: 60/255))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 10)
                
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
        }
    }
}
