//
//  WorkoutData.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/2/24.
//

import Foundation

class WorkoutData: ObservableObject {
    @Published var exerciseWeights: [String: [Int]] = [:]

    init() {
        loadWeights()
    }

    func loadWeights() {
        if let jsonString = UserDefaults.standard.string(forKey: "exerciseWeights"),
           let data = jsonString.data(using: .utf8) {
            do {
                self.exerciseWeights = try JSONDecoder().decode([String: [Int]].self, from: data)
            } catch {
                print("Error loading weights from UserDefaults:", error)
            }
        }
    }

    func saveWeights() {
        do {
            let jsonData = try JSONEncoder().encode(self.exerciseWeights)
            let jsonString = String(data: jsonData, encoding: .utf8)
            UserDefaults.standard.set(jsonString, forKey: "exerciseWeights")
        } catch {
            print("Error saving weights to UserDefaults:", error)
        }
    }
}
