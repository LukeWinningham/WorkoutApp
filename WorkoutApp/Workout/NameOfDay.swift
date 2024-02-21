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
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(exercises.indices, id: \.self) { index in
                        let exercise = exercises[index]
                        ExerciseView(exercise: exercise)
                            .onTapGesture {
                                selectedExerciseIndex = index
                                showingExerciseView = true
                            }
                    }
                }
                .padding(.horizontal)
            }
            .border(Color.gray, width: 0.2)
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
            
            let currentPackID = currentPackReference.recordID.recordName
            print("Current pack ID: \(currentPackID)")
            
            // Fetch DayID and Order from PackDays where PackID matches CurrentPack
            let packDaysPredicate = NSPredicate(format: "PackID == %@", currentPackReference.recordID)
            let packDaysQuery = CKQuery(recordType: "PackDay", predicate: packDaysPredicate)
            
            publicDB.perform(packDaysQuery, inZoneWith: nil) { (packDaysRecords, packDaysError) in
                if let packDaysError = packDaysError {
                    print("Error fetching pack days: \(packDaysError.localizedDescription)")
                    return
                }
                
                if let packDaysRecords = packDaysRecords, !packDaysRecords.isEmpty {
                    print("Found \(packDaysRecords.count) pack days.")
                } else {
                    print("No pack days found.")
                    return
                }
                
                guard let packDaysRecord = packDaysRecords?.first,
                      let dayID = packDaysRecord["DayID"] as? String,
                      let order = packDaysRecord["Order"] as? Int else {
                    print("No pack days found.")
                    return
                }
                
                print("Day ID: \(dayID), Order: \(order)")
                
                // Fetch exercises using DayID and Order
                let dayIDReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: dayID), action: .none)
                let dayOrderReference = CKRecord.Reference(recordID: CKRecord.ID(recordName: String(order)), action: .none)

                let exercisesPredicate = NSPredicate(format: "DayID == %@", dayIDReference)
                let exercisesQuery = CKQuery(recordType: "PackExercises", predicate: exercisesPredicate)
            
                
                publicDB.perform(exercisesQuery, inZoneWith: nil) { (records, error) in
                    if let error = error {
                        print("Error fetching exercises: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let records = records else {
                        print("No exercises fetched.")
                        return
                    }
                    
                    print("Fetched \(records.count) exercises.")
                    
                    DispatchQueue.main.async {
                        self.exercises = records.map { record in
                            ExerciseDetail(
                                chosenExercise: record["ChosenExercise"] as? String ?? "Unknown",
                                sets: record["Sets"] as? Int ?? 0,
                                time: record["Time"] as? Int ?? 0 // Assuming 'Time' is stored in seconds
                            )
                        }
                        
                        if self.exercises.isEmpty {
                            print("No exercises for today.")
                        } else {
                            print("Exercises loaded successfully.")
                        }
                    }
                }
            }
        }
    }
}
   struct ExerciseView: View {
       var exercise: ExerciseDetail

       var body: some View {
           VStack(alignment: .leading, spacing: 5) {
               Text(exercise.chosenExercise)
                   .font(.headline)
               Text("Sets: \(exercise.sets)")
                   .font(.subheadline)
               if exercise.time > 0 {
                   Text("Time: \(exercise.time) seconds")
                       .font(.subheadline)
               }
           }
           .padding()
           .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
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

