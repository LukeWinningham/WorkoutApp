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

                AddView()
                    .tabItem {
                        Image(systemName: "calendar.badge.plus")
                        Text("Plan")
                    }
                    .tag(1)

                Text("Coming Soon...")
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Progress")
                    }
                    .tag(2)

                ProfileView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .tag(3)
            }
            .navigationBarTitle("", displayMode: .inline)
            .foregroundColor(Color(red: 0/255, green: 211/255, blue: 255/255))
        }
        .onAppear {
            UITabBar.appearance().unselectedItemTintColor = UIColor(Color(red: 199/255, green: 199/255, blue: 199/255))
            UITabBar.appearance().backgroundColor = UIColor(Color(red: 20/255, green: 20/255, blue: 20/255))
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
