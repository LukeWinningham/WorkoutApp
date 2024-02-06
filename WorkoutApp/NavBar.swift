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

    var body: some View {
        NavigationView {
            TabView(selection: $navigationState.selectedTab) {
                Welcome() // This line adds the Welcome view back as the first tab's content
                    .tabItem {
                        Image(systemName: "dumbbell")
                        Text("Today")
                    }
                    .tag(0)

                Text("Coming Soon...")
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .tag(1)

                Text("Coming Soon...")
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Progress")
                    }
                    .tag(2)

                Text("Coming Soon...")
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .tag(3)
            }
            .navigationBarTitle("", displayMode: .inline)
            .foregroundColor(Color(red: 1.0, green: 0.677, blue: 0.215))
        }
        .onAppear {
            UITabBar.appearance().unselectedItemTintColor = .darkGray
            UITabBar.appearance().backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0.9)
        }
    }
}

struct NavBar_Previews: PreviewProvider {
    static var previews: some View {
        let navigationState = NavigationState()
        let weekData = WeekData.shared // Assuming this is how you initialize WeekData
        let workoutData = WorkoutData() // Assuming this is how you initialize WorkoutData

        NavBar()
            .environmentObject(navigationState)
            .environmentObject(weekData)
            .environmentObject(workoutData)
    }
}
