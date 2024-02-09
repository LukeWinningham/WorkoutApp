//
//  WorkoutList.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/5/24.
//

import SwiftUI
import Combine

struct WorkoutList: View {
    @State private var showingExerciseView = false
    @EnvironmentObject var weekData: WeekData
    @EnvironmentObject var workoutData: WorkoutData // Access WorkoutData from the environment
    @State private var selectedExerciseIndex: Int?

    var body: some View {
        Group {
            if let todayTasks = weekData.days.first(where: { $0.name == getCurrentDay() }), !todayTasks.items.isEmpty {
                List {
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
                .scrollContentBackground(.hidden)
                .listRowBackground(Color.clear)

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
    private func getCurrentDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: Date())
    }

}


struct WorkoutList_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutList()
            .environmentObject(WeekData.shared)
            .environmentObject(WorkoutData())
    }
}
