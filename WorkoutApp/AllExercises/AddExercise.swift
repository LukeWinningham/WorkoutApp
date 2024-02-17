//
//  SwiftUIView.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/12/24.
//
import SwiftUI

struct ExerciseSet: Identifiable, Equatable {
    let id: UUID = UUID()
    var reps: Int
    var timeInMinutes: Int? // Optional time for cardio exercises
}

struct AddExercise: View {
    let exerciseName: String
    let exerciseCategory: String

    @Environment(\.presentationMode) var presentationMode
    @State private var exerciseSets: [ExerciseSet]

    init(exerciseName: String, exerciseCategory: String) {
        self.exerciseName = exerciseName
        self.exerciseCategory = exerciseCategory
        _exerciseSets = State(initialValue: [ExerciseSet(reps: 10, timeInMinutes: nil)])
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 18/255, green: 18/255, blue: 18/255)
                .edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.backward")
                                .imageScale(.small)
                                .font(.title)
                                .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                                .shadow(radius: 3)
                        }
                    }
                }
            VStack(spacing: 30) {
                VStack{
                    HStack {
                        Spacer()
                        Text(exerciseName)
                            .font(.largeTitle)
                            .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                        Spacer()
                    }
                    Text(exerciseCategory)
                        .font(.title3)
                        .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                }
                Circle()
                    .frame(width: 160.0, height: 160.0)
                    .foregroundColor(Color(red: 0/255, green: 117/255, blue: 255/255))
                    .overlay(
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4) // Add a white stroke around the circle
                            
                            if exerciseCategory == "Cardio" {
                                Image(systemName: "figure.run") // Image for Cardio
                                    .resizable()
                                    .scaledToFit() // Ensure the image fits within the frame
                                    .frame(width: 100.0, height: 100.0)
                                    .foregroundColor(Color(red: 18/255, green: 18/255, blue: 18/255)) // Set the foreground color to white
                            } else {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .resizable()
                                    .scaledToFit() // Ensure the image fits within the frame
                                    .frame(width: 100.0, height: 100.0)
                                    .foregroundColor(Color(red: 18/255, green: 18/255, blue: 18/255)) // Set the foreground color to white
                            }
                        }
                    )

                ScrollView {
                    ForEach(exerciseSets.indices, id: \.self) { index in
                        let exerciseSet = exerciseSets[index]
                        HStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 41/255, green: 41/255, blue: 41/255))
                                .frame(height: 70)
                                .shadow(radius: 5)
                                .opacity(0.3)
                                .overlay(
                                    HStack {
                                        if exerciseCategory == "Cardio" {
                                            Text("Time:")
                                                .font(.system(size: 30))
                                                .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                                                .padding(.leading, 15.0)
                                            // Use Picker for time input
                                            Picker("Minutes", selection: $exerciseSets[index].timeInMinutes) {
                                                ForEach(1...12, id: \.self) { number in
                                                    Text("\(number * 15) min")
                                                        .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                                                        .tag(number * 15)
                                                }
                                            }
                                            .pickerStyle(WheelPickerStyle())
                                            .frame(width: 100)
                                            Spacer()
                                        } else {
                                            Text("Set: \(index + 1)")
                                                .font(.system(size: 30))
                                                .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                                                .padding(.leading, 15.0)
                                            
                                            Spacer()
                                            
                                            Text("Reps:")
                                                .font(.system(size: 30))
                                                .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                                            
                                            Picker("Reps", selection: $exerciseSets[index].reps) {
                                                ForEach(1...99, id: \.self) { number in
                                                    Text("\(number)")
                                                        .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                                                        .tag(number)
                                                }
                                            }
                                            .pickerStyle(WheelPickerStyle())
                                            .frame(width: 100)
                                        }
                                    }
                                )
                        }
                    }
                }
                Button(action: addSet) {
                    Text("Add Set")
                        .padding()
                        .frame(width: 130.0, height: 45.0)
                        .background(Color(red: 41/255, green: 41/255, blue: 41/255))
                        .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                        .cornerRadius(10)
                }

            }
            .padding()
        }
    }

    private func addSet() {
        let newSet = ExerciseSet(reps: 10, timeInMinutes: nil) // Default to 10 reps and nil time
        exerciseSets.append(newSet)
    }
}

struct AddExercise_Previews: PreviewProvider {
    static var previews: some View {
        AddExercise(exerciseName: "Bench Press", exerciseCategory: "Cardio")
    }
}
