//
//  WorkoutData.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/2/24.
//

import Foundation

class WorkoutData: ObservableObject {
    @Published var exerciseWeights: [String: [Int]] = [:]
    @Published var done: Int {
        didSet {
            UserDefaults.standard.set(done, forKey: "done")
        }
    }

    private var lastSavedDate: String? {
        didSet {
            UserDefaults.standard.set(lastSavedDate, forKey: "lastSavedDate")
        }
    }

    init() {
        self.done = UserDefaults.standard.integer(forKey: "done")
        self.lastSavedDate = UserDefaults.standard.string(forKey: "lastSavedDate")

        loadWeights()
        resetDoneIfNeeded()
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

    private func resetDoneIfNeeded() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())

        if lastSavedDate != today {
            done = 0 // Reset done to zero if the day has changed
            lastSavedDate = today // Update lastSavedDate to today
        }
    }
}
