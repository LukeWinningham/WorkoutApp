//
//  NameOfDay.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/5/24.
//

import SwiftUI
import Combine
import CloudKit
import ActivityKit
import WidgetKit

struct NameOfDay: View {
    @State private var showingExerciseView = false
    @State private var selectedExerciseIndex: Int?
    @State private var exercises: [ExerciseDetail] = []
    @State private var dayName: String = ""
    @State private var currentExerciseIndex = 0
    @State private var currentSet = 1
    @State private var workoutStarted = false
    @State private var currentActivity: Activity<WorkoutAttributes>?
    @State private var currentReps = 0 // Added state for current reps

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
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 18/255, green: 18/255, blue: 18/255))
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                Spacer(minLength: 20)
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
                if workoutStarted && currentExerciseIndex < exercises.count {
                    Text("Exercise: \(exercises[currentExerciseIndex].chosenExercise)")
                        .foregroundColor(.white)
                        .padding()

                    Text("Set: \(currentSet) of \(exercises[currentExerciseIndex].sets)")
                        .foregroundColor(.white)
                        .padding()


                    HStack {
                        Button(action: {
                            goToPrevious()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }

                        Button(action: {
                            goToNext()
                        }) {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    Button("Start Workout") {
                        startWorkout()
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
        }
        .onAppear(perform: loadExercises)
    }

    private func startWorkout() {
        workoutStarted = true
        currentExerciseIndex = 0
        currentSet = 1
        Task {
            await startLiveActivity()
        }
    }

    private func goToNext() {
        let currentExercise = exercises[currentExerciseIndex]
        if currentSet < currentExercise.sets {
            currentSet += 1
        } else if currentExerciseIndex < exercises.count - 1 {
            currentExerciseIndex += 1
            currentSet = 1
        } else {
            print("Workout completed!")
            workoutStarted = false
            
            Task {
                await endLiveActivity()
            }
        }
        
        Task {
            await updateLiveActivity()
        }
    }

    private func goToPrevious() {
        if currentSet > 1 {
            currentSet -= 1
        } else if currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
            currentSet = exercises[currentExerciseIndex].sets
        } else {
            print("Beginning of workout")
        }
        
        Task {
            await updateLiveActivity()
        }
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
                    self.dayName = dayName
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
                        self.exercises = records?.compactMap { record in
                            guard let chosenExercise = record["ChosenExercise"] as? String,
                                  let sets = record["Sets"] as? Int,
                                  let time = record["Time"] as? Int else {
                                print("Missing data in record: \(record)")
                                return nil
                            }
                            let repsPerSet = self.fetchRepsDataFromPackExercises(for: record)
                            print("Exercise: \(chosenExercise), Sets: \(sets), Time: \(time), Reps Per Set: \(repsPerSet)")
                            return ExerciseDetail(
                                chosenExercise: chosenExercise,
                                sets: sets,
                                time: time,
                                repsPerSet: repsPerSet
                            )
                        } ?? []
                    }

                }
            }
        }
    }


    private func fetchRepsDataFromPackExercises(for record: CKRecord) -> [Int] {
        guard let repsData = record["Reps"] as? Data else {
            print("Reps data not found.")
            return []
        }
        do {
            let decoder = JSONDecoder()
            let repsArray = try decoder.decode([Int].self, from: repsData)
            return repsArray
        } catch {
            print("Error decoding reps data: \(error)")
            return []
        }
    }

    

    @MainActor
    private func startLiveActivity() async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Activities are not enabled.")
            return
        }

        do {
            let attributes = WorkoutAttributes()
            let initialContentState = WorkoutAttributes.ContentState(
                exerciseName: exercises[currentExerciseIndex].chosenExercise,
                currentSet: currentSet,
                totalSets: exercises[currentExerciseIndex].sets,
                repsPerSet: []
            )

            let activity = try Activity<WorkoutAttributes>.request(
                attributes: attributes,
                contentState: initialContentState,
                pushType: nil
            )

            self.currentActivity = activity
        } catch {
            print("Failed to request activity: \(error)")
        }
    }

    @MainActor private func updateLiveActivity() async {
        guard let activity = currentActivity else { return }

        let updatedContentState = WorkoutAttributes.ContentState(
            exerciseName: exercises[currentExerciseIndex].chosenExercise,
            currentSet: currentSet,
            totalSets: exercises[currentExerciseIndex].sets,
            repsPerSet: []
        )

        await activity.update(using: updatedContentState)
    }

    @MainActor private func endLiveActivity() async {
        await currentActivity?.end(dismissalPolicy: .immediate)
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
    var time: Int
    var repsPerSet: [Int] // Add repsPerSet property

    init(chosenExercise: String, sets: Int, time: Int, repsPerSet: [Int]) { // Update initializer
        self.chosenExercise = chosenExercise
        self.sets = sets
        self.time = time
        self.repsPerSet = repsPerSet
    }
}


// Dummy preview provider
struct NameOfDay_Previews: PreviewProvider {
    static var previews: some View {
        NameOfDay().environmentObject(AuthViewModel())
    }
}
