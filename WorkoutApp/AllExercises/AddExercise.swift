//
//  SwiftUIView.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/12/24.
//

import SwiftUI
import CloudKit

struct ExerciseSet: Identifiable, Equatable {
    let id: UUID = UUID()
    var reps: Int
    var timeInMinutes: Int? // Optional time for cardio exercises
}

struct AddExercise: View {
    let exerciseName: String
    let exerciseCategory: String
    let dayID: CKRecord.ID
    
    @Environment(\.presentationMode) var presentationMode
    @State private var exerciseSets: [ExerciseSet] = [ExerciseSet(reps: 10, timeInMinutes: nil)]
    let database = CKContainer.default().publicCloudDatabase

    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 18/255, green: 18/255, blue: 18/255)
                .edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.backward").foregroundColor(.white)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            saveExerciseToCloudKit()
                        }
                        .foregroundColor(.white)
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
                .padding()

                Circle()
                    .frame(width: 160.0, height: 160.0)
                    .foregroundColor(Color(red: 0/255, green: 117/255, blue: 255/255))
                    .overlay(
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                            Image(systemName: exerciseCategory == "Cardio" ? "figure.run" : "figure.strengthtraining.traditional")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100.0, height: 100.0)
                                .foregroundColor(Color(red: 18/255, green: 18/255, blue: 18/255))
                        }
                    )

                ScrollView {
                    ForEach($exerciseSets) { $exerciseSet in
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
                                                .foregroundColor(Color.white)
                                                .padding(.leading, 15.0)
                                            Picker("Minutes", selection: $exerciseSet.timeInMinutes) {
                                                ForEach(1...12, id: \.self) { number in
                                                    Text("\(number * 15) min").tag(number * 15)
                                                }
                                            }
                                            .pickerStyle(WheelPickerStyle())
                                            .frame(width: 100)
                                            Spacer()
                                        } else {
                                            Text("Set: \(exerciseSets.firstIndex(where: { $0.id == exerciseSet.id })! + 1)")
                                                .font(.system(size: 30))
                                                .foregroundColor(Color.white)
                                                .padding(.leading, 15.0)
                                            Spacer()
                                            Text("Reps:")
                                                .font(.system(size: 30))
                                                .foregroundColor(Color.white)
                                            Picker("Reps", selection: $exerciseSet.reps) {
                                                ForEach(1...99, id: \.self) { number in
                                                    Text("\(number)").tag(number)
                                                }
                                            }
                                            .pickerStyle(WheelPickerStyle())
                                            .frame(width: 100)
                                        }
                                    }
                                )
                        }
                        .padding(.horizontal)
                    }
                }

                Button("Add Set") {
                    addSet()
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .foregroundColor(.white)

            }
            .padding()
        }
    }

    private func addSet() {
        exerciseSets.append(ExerciseSet(reps: 10, timeInMinutes: nil))
    }

    private func saveExerciseToCloudKit() {
        for exerciseSet in exerciseSets {
            let record = CKRecord(recordType: "PackExercises")
            record["ChosenExercise"] = exerciseName
            record["DayID"] = CKRecord.Reference(recordID: dayID, action: .none)
            record["Reps"] = exerciseSet.reps
            if let time = exerciseSet.timeInMinutes {
                record["Time"] = time
            } else {
                // Assume 'Sets' is the number of items in 'exerciseSets'
                record["Sets"] = exerciseSets.count
            }
            
            database.save(record) { _, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error saving exercise to CloudKit: \(error.localizedDescription)")
                    } else {
                        print("Successfully saved exercise to CloudKit")
                    }
                }
            }
        }
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct AddExercise_Previews: PreviewProvider {
    static var previews: some View {
        AddExercise(exerciseName: "Bench Press", exerciseCategory: "Cardio", dayID: CKRecord.ID(recordName: UUID().uuidString))
    }
}


