//
//  ContentView.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 1/29/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var weekData: WeekData
    @EnvironmentObject var workoutData: WorkoutData // Access WorkoutData from the environment

    @State private var currentDate = UserDefaults.standard.string(forKey: "currentDateKey") ?? ""
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                TodayView()
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
    private func getCurrentDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: Date())
    }
 
}

struct TodayView: View {
    @EnvironmentObject var weekData: WeekData
    @EnvironmentObject var workoutData: WorkoutData // Access WorkoutData from the environment
    @State private var showingAddView = false
    @State private var showingExerciseView = false
    @State private var selectedExerciseIndex: Int?

    var body: some View {
        ZStack {
            Color(red: 217/255, green: 217/255, blue: 217/255).edgesIgnoringSafeArea(.all)
            VStack {
                welcomeSection
                dayTitle
            
                // Check the value of workoutData.done
                if workoutData.done == 2 {
                    // Show an image when workoutData.done equals 2
                    Image("Image") // Make sure to replace "YourImage" with the actual name of your image in the asset catalog
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)
                    Text("Great Job! You CRUSHED It Today.")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .bold()
                        .foregroundColor(Color(red: 0.067, green: 0.69, blue: 0.951))
                } else {
                    // Otherwise, show today's tasks
                    workoutsList
                    startWorkoutButton
                }

                Spacer()
            }
        }
    }

    private var welcomeSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Welcome Back,").foregroundColor(.gray).font(.body)
                Text("Luke").foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255)).font(.title).bold()
            }
            Spacer()
            Button(action: { showingAddView = true }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.677, blue: 0.215))
                    .frame(width: 50, height: 50)
                    .imageScale(.large)
            }
            .sheet(isPresented: $showingAddView) {
                AddView(weekData: _weekData)
            }
        }
        .padding()
    }

    private var dayTitle: some View {
        VStack{
            Text("Today is \(getCurrentDay())!")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255))
                .padding(.top, 20)
            
        }
    }

    private var workoutsList: some View {
        Group {
            if let todayTasks = weekData.days.first(where: { $0.name == getCurrentDay() }), !todayTasks.items.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 5) {
                        ForEach(Array(todayTasks.items.enumerated()), id: \.element.id) { index, uniqueItem in
                            // Wrap each task in a RoundedRectangle
                            Spacer()
                            RoundedRectangle(cornerRadius: 10) // Adjust cornerRadius as needed
                                .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.908)) // Use any color that fits your design
                                .frame(height: 70) // Adjust height as needed
                                .shadow(radius: 5) // Adjust shadow radius as needed
                                .overlay(
                                    HStack(spacing: 20) {
                                        Circle()
                                            .foregroundColor(Color(red: 0.07, green: 0.69, blue: 0.951))
                                            .frame(width: 45.0, height: 45.0) // Adjust the size of the circle as needed
                                            .opacity(0.5)
                                        Text(uniqueItem.value)
                                            .foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255))
                                            .font(.system(size: 20))
                                        Spacer()
                                    }
                                    .padding(.horizontal) // Add some horizontal padding inside the RoundedRectangle
                                )
                                .onTapGesture {
                                    selectedExerciseIndex = index
                                    showingExerciseView = true
                                }
                                .sheet(isPresented: $showingExerciseView) {
                                    Exercise(exerciseIndex: selectedExerciseIndex ?? 0)
                                        .environmentObject(weekData)
                                        .environmentObject(WorkoutData())
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .border(Color.gray, width: 0.2)
            } else {
                VStack {
                    Image("Image")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 380, height: 380)
                        .clipped()
                    Text("Relax, You EARNED It!")
                        .font(.title)
                        .foregroundColor(Color(red: 0.067, green: 0.69, blue: 0.951))
                        .bold()
                }
            }
        }
    }

   


    private var startWorkoutButton: some View {
        Group {
            if let todayTasks = weekData.days.first(where: { $0.name == getCurrentDay() }), !todayTasks.items.isEmpty{
                // Only show the "Start Workout" button if there are workouts for today
                NavigationLink(destination: WorkoutDetails().environmentObject(weekData).environmentObject(WorkoutData())) {
                    ZStack {
                        VStack{
                  
                            ZStack{
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 0.067, green: 0.69, blue: 0.951), Color(hue: 1.0, saturation: 0.251, brightness: 0.675)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 180, height: 50)
                                    .opacity(0.7)
                                Text("Start Workout")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                        }
                    }
                    .padding()
                }
             
            }
        }
    }

    private func getCurrentDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: Date())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Initialize your environment objects
        let weekData = WeekData.shared
        let workoutData = WorkoutData()

        // Provide the environment objects to ContentView
        ContentView()
            .environmentObject(weekData)
            .environmentObject(workoutData)
    }
}
