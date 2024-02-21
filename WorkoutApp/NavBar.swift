//
//  NavBar.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/5/24.
//
import SwiftUI
import Combine

struct NavBar: View {
    @EnvironmentObject var navigationState: NavigationState
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            TabView(selection: $navigationState.selectedTab) {
                
                Welcome() // This line adds the Welcome view back as the first tab's content
                    .tabItem {
                        Image(navigationState.selectedTab == 0 ? "dd" : "dumbbell")
                        Text("Today")
                    }
                    .tag(0)
            
                Discovery()
                    .tabItem {
                        Image(systemName: navigationState.selectedTab == 2 ? "sparkle.magnifyingglass" : "magnifyingglass")
                        Text("Discover")
                    }
                    .tag(2)
                
                AddView().environmentObject(authViewModel)
                    .tabItem {
                        Image(navigationState.selectedTab == 1 ? "list" : "list.bullet.circle")
                        Text("Plan")
                    }
                    .tag(1)
            }
            .navigationBarTitle("", displayMode: .inline)
        }
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.backgroundColor = UIColor(Color(red: 20/255, green: 20/255, blue: 20/255))
            let titleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)] // Adjust this value as needed
                     tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = titleAttributes
                     tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = titleAttributes

            // Set both selected and unselected item color to the same value
            let itemTintColor = UIColor(Color(red: 199/255, green: 199/255, blue: 199/255))
            tabBarAppearance.stackedLayoutAppearance.normal.iconColor = itemTintColor
            tabBarAppearance.stackedLayoutAppearance.selected.iconColor = itemTintColor
            tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: itemTintColor]
            tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: itemTintColor]

            UITabBar.appearance().standardAppearance = tabBarAppearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }
    }
}


struct NavBar_Previews: PreviewProvider {
    static var previews: some View {
        let navigationState = NavigationState()
      
        let workoutData = WorkoutData() // Assuming this is how you initialize WorkoutData
        let authViewModel = AuthViewModel()
        NavBar()
            .environmentObject(navigationState)
            .environmentObject(workoutData)
            .environmentObject(authViewModel)
    }
}
