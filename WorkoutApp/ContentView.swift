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
    @State private var done = UserDefaults.standard.integer(forKey: "doneKey")
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
            if currentDate != getCurrentDay() {
                          // If the stored date is different from the current day, reset 'done' to 0
                            done = 0
                          UserDefaults.standard.set(0, forKey: "doneKey")
                          
                          // Update the stored date to the current day
                          UserDefaults.standard.set(getCurrentDay(), forKey: "currentDateKey")
                          self.currentDate = getCurrentDay()
                      }
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
    @State private var showingAddView = false
    @State private var showingExerciseView = false
    @State private var selectedExerciseIndex: Int?
    @State private var done = UserDefaults.standard.integer(forKey: "doneKey")

    var body: some View {
        ZStack {
            Color(red: 217/255, green: 217/255, blue: 217/255).edgesIgnoringSafeArea(.all)
            VStack {
                welcomeSection
                dayTitle
                workoutsList
                startWorkoutButton
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
            if let todayTasks = weekData.days.first(where: { $0.name == getCurrentDay() }), !todayTasks.items.isEmpty, done < 1 {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(Array(todayTasks.items.enumerated()), id: \.element.id) { index, uniqueItem in
                            VStack {
                                HStack(spacing: 20) {
                                    Circle()
                                        .foregroundColor(Color(red: 0.07, green: 0.69, blue: 0.951))
                                        .frame(width: 50, height: 40)
                                        .shadow(radius: 5)
                                        .opacity(0.5)
                                    Text(uniqueItem.value)
                                        .foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255))
                                        .font(.system(size: 20))
                                    Spacer()
                                }
                                .onTapGesture {
                                    selectedExerciseIndex = index
                                    showingExerciseView = true
                                }
                                .sheet(isPresented: $showingExerciseView) {
                                    if let index = selectedExerciseIndex {
                                        Exercise(exerciseIndex: index)
                                    }
                                }
                                .padding()
                                Divider()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .border(Color.gray, width: 0.2)
            } else {
                VStack {
                    Image("Image") // Make sure you have this image in your assets
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 380, height: 380)
                        .clipped()
                    Text("Relax, You EARNED It!")
                        .font(.title)
                        .foregroundColor(Color(red: 0.067, green: 0.69, blue: 0.951))
                        .bold()
                }
                // This VStack won't be in a ScrollView and won't have a border
            }
        }
    }


    private var startWorkoutButton: some View {
        Group {
            if let todayTasks = weekData.days.first(where: { $0.name == getCurrentDay() }), !todayTasks.items.isEmpty, done < 1 {
                // Only show the "Start Workout" button if there are workouts for today
                NavigationLink(destination: WorkoutDetails()) {
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
        ContentView().environmentObject(WeekData.shared)
    }
}
