//
//  ExerciseViewModel.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/10/24.
//

import Foundation
import SwiftUI
import CloudKit

struct Exercises: Identifiable {
    let id = UUID()
    var name: String
    var exercises: [String]
}

class ExercisesViewModel: ObservableObject {
    @Published var exercises: [Exercises] = []
    private var container: CKContainer
    private var publicDatabase: CKDatabase
    
    init() {
        container = CKContainer.default()
        publicDatabase = container.publicCloudDatabase
    }
    
    func loadExercises() {
        let recordType = "Exercises"
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)

        queryOperation.recordMatchedBlock = { [weak self] (recordID, result) in
            switch result {
            case .success(let record):
                self?.processRecord(record)
            case .failure(let error):
                print("Failed to fetch record with ID \(recordID): \(error)")
            }
        }

        queryOperation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Handle completion, if necessary
                    break
                case .failure(let error):
                    print("Query operation failed with error: \(error)")
                }
            }
        }

        publicDatabase.add(queryOperation)
    }

    private func processRecord(_ record: CKRecord) {
        let categoryFields = [
            "Abs", "Biceps", "Calves", "Glutes", "Hamstrings", "LowerBack",
            "LowerChest", "Obliques", "Other", "Quads", "Shoulders", "Triceps",
            "UpperBack", "UpperChest"
        ]
        
        for field in categoryFields {
            if let exercises = record[field] as? [String], !exercises.isEmpty {
                DispatchQueue.main.async {
                    self.exercises.append(Exercises(name: field, exercises: exercises))
                }
            }
        }
    }
}
