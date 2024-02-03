//
//  Exercise.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 1/31/24.
//
import SwiftUI
import Combine

struct Exercise: View {
    @ObservedObject var weekData = WeekData.shared
    @EnvironmentObject var workoutData: WorkoutData
    @State private var newDes: String = ""

    var exerciseIndex: Int

    init(exerciseIndex: Int) {
        self.exerciseIndex = exerciseIndex
        // Initialize newDes with the description of the current exercise
        if let currentDayIndex = weekData.days.firstIndex(where: { $0.name == getCurrentDay() }) {
            _newDes = State(initialValue: weekData.days[currentDayIndex].items[exerciseIndex].description)
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 217/255, green: 217/255, blue: 217/255).edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                if let todayWorkout = weekData.days.first(where: { $0.name == getCurrentDay() }),
                   todayWorkout.items.indices.contains(exerciseIndex) {
                    let exerciseName = todayWorkout.items[exerciseIndex].value
                    let exerciseWeights = workoutData.exerciseWeights[exerciseName] ?? []
                    let personalBest = exerciseWeights.max() ?? 0
                    let lastThreeWeights = exerciseWeights.suffix(3)

                    RoundedRectangle(cornerRadius: 50)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 0.067, green: 0.69, blue: 0.951), Color(hue: 1.0, saturation: 0.251, brightness: 0.675)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 440.0, height: 580)
                        .shadow(radius: 20)
                        .overlay(
                            VStack(spacing: 15) {
                                ExerciseDetails(todayWorkout: todayWorkout, exerciseIndex: exerciseIndex)
                                PersonalBestText(personalBest: personalBest)
                                LastThreeSetsText(lastThreeWeights: lastThreeWeights)
                                
                                TextField("Description", text: $newDes)
                                    .foregroundColor(.white)
                                    .padding(.leading, 50)
                                    .padding(.top, 30)
                                    .onReceive(Just(newDes)) { _ in
                                        saveDescription()
                                    }

                                Spacer()
                            }
                        )
                        .padding(.bottom, -60)
                } else {
                    Text("Exercise Not Found")
                        .font(.largeTitle)
                        .foregroundColor(.white)
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

    private func saveDescription() {
        if let currentDayIndex = weekData.days.firstIndex(where: { $0.name == getCurrentDay() }) {
            weekData.days[currentDayIndex].items[exerciseIndex].description = newDes
            weekData.saveToUserDefaults()
        }
    }
}

struct ExerciseDetails: View {
    var todayWorkout: Day
    var exerciseIndex: Int

    var body: some View {
        if let numberSets = todayWorkout.items[exerciseIndex].numberSets, let numberReps = todayWorkout.items[exerciseIndex].numberReps {
            Text("You have \(numberSets) sets of \(numberReps) reps of")
                .font(.title3)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
            Text(todayWorkout.items[exerciseIndex].value)
                .font(.largeTitle)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .bold()
                .padding(.horizontal, 45.0)
        } else if let time = todayWorkout.items[exerciseIndex].time {
            Text("You have \(time) minutes of")
                .font(.title3)
                .foregroundColor(Color(red: 217/255, green: 217/255, blue: 217/255))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
            Text(todayWorkout.items[exerciseIndex].value)
                .font(.largeTitle)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .bold()
        }
    }
}

struct PersonalBestText: View {
    let personalBest: Int

    var body: some View {
        VStack {
            Text("Personal Best")
                .font(.title3)
                .foregroundColor(Color(red: 217/255, green: 217/255, blue: 217/255))
            Text("\(personalBest)")
                .font(.title3)
                .foregroundColor(Color(red: 217/255, green: 217/255, blue: 217/255))
                .bold()
        }
    }
}

struct LastThreeSetsText: View {
    let lastThreeWeights: ArraySlice<Int>

    var body: some View {
        VStack {
            Text("Last 3 Sets")
                .font(.title3)
                .foregroundColor(Color(red: 217/255, green: 217/255, blue: 217/255))
            Text(lastThreeWeights.map { "\($0)" }.joined(separator: ", "))
                .font(.title3)
                .foregroundColor(Color(red: 217/255, green: 217/255, blue: 217/255))
                .bold()
        }
    }
}

struct Exercise_Previews: PreviewProvider {
    static var previews: some View {
        Exercise(exerciseIndex: 0)
            .environmentObject(WeekData.shared)
            .environmentObject(WorkoutData())
    }
}
