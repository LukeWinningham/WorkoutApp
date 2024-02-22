//
//  NameOfDay.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/5/24.
//


import SwiftUI
import Combine
import CloudKit

struct NameOfDay: View {
    @State private var showingExerciseView = false
    @State private var selectedExerciseIndex: Int?
    @State private var exercises: [ExerciseDetail] = [] // Use a struct to hold exercise details
    @State private var dayName: String = "" // State property for day name
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color(red: 18/255, green: 18/255, blue: 18/255).edgesIgnoringSafeArea(.all)
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
            VStack {
                
                Text(dayName)
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
                    .padding()
                
                    .frame(maxWidth: .infinity) // Ensure the header stretches across the screen
                                  .background(Color(red: 18/255, green: 18/255, blue: 18/255)) // Background color of the header
                                  .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                Spacer(minLength: 20) // Add spacer or padding to create space between day name and scroll view

                ScrollView {
                 

                    LazyVStack(spacing: 10) {
                        ForEach(exercises.indices, id: \.self) { index in
                            let exercise = exercises[index]
                            ExerciseView(exercise: exercise)
                                .onTapGesture {
                                    selectedExerciseIndex = index
                                    showingExerciseView = true
                                }
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 41/255, green: 41/255, blue: 41/255))
                                    .frame(height: 70)
                                    .shadow(radius: 5))
                                .padding(.horizontal)
                                .padding(.top, 25)
                        }
                    }
                }
                
                
            }
        }
        
        .onAppear(perform: loadExercises)
    }

    private func loadExercises() {
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase

        guard let userIdentifier = authViewModel.userIdentifier, !userIdentifier.isEmpty else {
            print("User identifier is not available.")
            return
        }

        let predicate = NSPredicate(format: "userIdentifier == %@", userIdentifier)
        let query = CKQuery(recordType: "PersonalData", predicate: predicate)

        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error fetching PersonalData record: \(error.localizedDescription)")
                return
            }

            guard let personalDataRecord = records?.first,
                  let currentPackReference = personalDataRecord["CurrentPack"] as? CKRecord.Reference else {
                print("No PersonalData record found or CurrentPack not available.")
                return
            }

            let packDaysPredicate = NSPredicate(format: "PackID == %@", currentPackReference.recordID)
            let packDaysQuery = CKQuery(recordType: "PackDay", predicate: packDaysPredicate)

            publicDB.perform(packDaysQuery, inZoneWith: nil) { (packDaysRecords, packDaysError) in
                if let packDaysError = packDaysError {
                    print("Error fetching pack days: \(packDaysError.localizedDescription)")
                    return
                }

                guard let packDaysRecord = packDaysRecords?.first,
                      let dayID = packDaysRecord["DayID"] as? String,
                      let dayName = packDaysRecord["DayName"] as? String else {
                    print("No pack days found.")
                    return
                }

                DispatchQueue.main.async {
                    self.dayName = dayName // Set the DayName to the state property
                }

                let dayIDReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: dayID), action: .none)
                let exercisesPredicate = NSPredicate(format: "DayID == %@", dayIDReference)
                let exercisesQuery = CKQuery(recordType: "PackExercises", predicate: exercisesPredicate)

                publicDB.perform(exercisesQuery, inZoneWith: nil) { (records, error) in
                    if let error = error {
                        print("Error fetching exercises: \(error.localizedDescription)")
                        return
                    }

                    DispatchQueue.main.async {
                        self.exercises = records?.map { record in
                            ExerciseDetail(
                                chosenExercise: record["ChosenExercise"] as? String ?? "Unknown",
                                sets: record["Sets"] as? Int ?? 0,
                                time: record["Time"] as? Int ?? 0 // Assuming 'Time' is stored in seconds
                            )
                        } ?? []
                    }
                }
            }
        }
    }
}

struct ExerciseView: View {
    var exercise: ExerciseDetail

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color(red: 0/255, green: 117/255, blue: 255/255))

                if exercise.time > 0 {
                    Image(systemName: "figure.run")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color.white)
                } else {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color.white)
                }
            }

            VStack(alignment: .leading) {
                Text(exercise.chosenExercise)
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)

                if exercise.sets > 0 {
                    Text("\(exercise.sets) Sets")
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray)
                }

                if exercise.time > 0 {
                    Text("Time: \(exercise.time) seconds")
                        .font(.system(size: 12))
                        .foregroundColor(Color.gray)
                }
            }
            Spacer()
        }
        .padding(.leading, 20)
    }
}

struct ExerciseDetail {
    var chosenExercise: String
    var sets: Int
    var time: Int // Time in seconds
}

// Dummy preview provider
struct NameOfDay_Previews: PreviewProvider {
    static var previews: some View {
        NameOfDay().environmentObject(AuthViewModel())
    }
}
