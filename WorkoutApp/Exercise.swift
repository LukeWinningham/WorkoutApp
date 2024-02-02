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
    @State private var newDes: String = ""

    var exerciseIndex: Int

    func getCurrentDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: Date())
    }

    init(exerciseIndex: Int) {
        self.exerciseIndex = exerciseIndex
        _newDes = State(initialValue: weekData.days[getCurrentDayIndex()].items[exerciseIndex].description)
    }

    func getCurrentDayIndex() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let today = dateFormatter.string(from: Date())
        return weekData.days.firstIndex(where: { $0.name == today }) ?? 0
    }

    func saveDescriptionToUserDefaults() {
        weekData.days[getCurrentDayIndex()].items[exerciseIndex].description = newDes
        weekData.saveToUserDefaults()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 217/255, green: 217/255, blue: 217/255).edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                if let todayWorkout = weekData.days.first(where: { $0.name == getCurrentDay() }), todayWorkout.items.indices.contains(exerciseIndex) {
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color(hue: 1.0, saturation: 0.251, brightness: 0.675))
                        .frame(width: 440.0, height: 580)
                        .shadow(radius: 20)
                        .overlay(
                            VStack(spacing: 40) {
                                VStack(spacing: 15) {
                                    if let numberSets = todayWorkout.items[exerciseIndex].numberSets, let numberReps = todayWorkout.items[exerciseIndex].numberReps {
                                        Text("You have \(numberSets) sets of \(numberReps) reps of")
                                            .font(.title3)
                                            .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.815))
                                            .padding(.top, 20)
                                        Text(todayWorkout.items[exerciseIndex].value)
                                            .font(.largeTitle)
                                            .foregroundColor(.white)
                                            .bold()

                                        VStack {
                                            Text("Personal Best")
                                                .font(.title3)
                                                .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.815))

                                            Text("450")
                                                .font(.title3)
                                                .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.815))
                                                .bold()
                                        }

                                        VStack {
                                            Text("Last 3 Sets")
                                                .font(.title3)
                                                .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.815))

                                            Text("450, 300, 200")
                                                .font(.title3)
                                                .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.815))
                                                .bold()
                                        }
                                    } else if let time = todayWorkout.items[exerciseIndex].time {
                                        Text("You have \(time) minutes of")
                                            .font(.title3)
                                            .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.815))
                                            .padding(.top, 20)
                                        Text(todayWorkout.items[exerciseIndex].value)
                                            .font(.largeTitle)
                                            .foregroundColor(.white)
                                            .bold()
                                    }

                                

                                }

                                TextField("Description", text: $newDes)
                                    .foregroundColor(.white)
                                    .padding(.leading, 50)
                                    .padding(.top, 30)
                                    .onReceive(Just(newDes)) { _ in
                                        saveDescriptionToUserDefaults()
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
}

struct Exercise_Previews: PreviewProvider {
    static var previews: some View {
        Exercise(exerciseIndex: 0).environmentObject(WeekData.shared)
    }
}
