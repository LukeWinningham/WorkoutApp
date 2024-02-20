//
//  WorkoutPacks.swift
//  Amson
//
//  Created by Luke Winningham on 2/17/24.
//
import Foundation
import SwiftUI
import CloudKit
import Combine


struct WorkoutPacks: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var packs = [UUID]()
    @State private var selectedPackID: UUID?

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                Color(red: 18/255, green: 18/255, blue: 18/255).edgesIgnoringSafeArea(.all)
                VStack {
                    headerView
                    packsListView
                }
            }
        }
        .onAppear {
            fetchPacks()
        }
    }

    var headerView: some View {
        HStack {
            Spacer()
            Text("Workout Packs").font(.title).foregroundColor(Color.white).padding()
            Spacer()
        }
    }

    var packsListView: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(packs, id: \.self) { packID in
                    workoutPackView(packID: packID)
                }
                newPackView
            }
            .padding(.horizontal)
        }
    }

    func workoutPackView(packID: UUID) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(selectedPackID == packID ? Color.green : Color.black)
                .frame(height: 200)
                .overlay(
                    selectedPackID == packID ?
                        Image(systemName: "checkmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color.white) : nil
                )
                .onTapGesture {
                    updateSelectedPack(packID: packID)
                }
            Text("Workout Pack").foregroundColor(Color.white)
        }
    }

    var newPackView: some View {
        Button(action: createWorkoutPack) {
            VStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.gray)
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color.green)
                    )
                Text("New Pack").foregroundColor(Color.white)
            }
        }
    }
    func updateSelectedPack(packID: UUID) {
        selectedPackID = selectedPackID == packID ? nil : packID
        updateCurrentPackInCloudKit(with: selectedPackID)
    }

    func createWorkoutPack() {
        let packID = UUID()
        let newPackRecord = CKRecord(recordType: "WorkoutPacks")
        newPackRecord["PackID"] = [packID.uuidString]  // Store the pack ID as an array of strings

        let database = CKContainer.default().publicCloudDatabase

        // Save the new WorkoutPacks record
        database.save(newPackRecord) { (savedRecord, error) in
            if let error = error {
                print("Error saving new pack: \(error.localizedDescription)")
                return
            }
            
            guard let savedRecord = savedRecord else {
                print("Failed to save new pack.")
                return
            }
            
            // Fetch the user's PersonalData record
            guard let userIdentifier = self.authViewModel.userIdentifier, !userIdentifier.isEmpty else {
                print("User identifier is not available.")
                return
            }

            let predicate = NSPredicate(format: "userIdentifier == %@", userIdentifier)
            let query = CKQuery(recordType: "PersonalData", predicate: predicate)
            
            database.perform(query, inZoneWith: nil) { records, error in
                guard let personalDataRecord = records?.first else {
                    print("PersonalData record not found for userIdentifier: \(userIdentifier). Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                // Update the AllPacks field with the reference to the new pack
                var allPacks = personalDataRecord["AllPacks"] as? [CKRecord.Reference] ?? []
                let newPackReference = CKRecord.Reference(recordID: savedRecord.recordID, action: .none)
                allPacks.append(newPackReference)
                personalDataRecord["AllPacks"] = allPacks
                
                // Save the updated PersonalData record
                database.save(personalDataRecord) { _, error in
                    if let error = error {
                        print("Failed to update PersonalData with AllPacks: \(error.localizedDescription)")
                    } else {
                        print("PersonalData updated successfully with the new pack.")
                    }
                }
            }
        }
    }



    func updateCurrentPackInCloudKit(with packID: UUID?) {
        guard let userIdentifier = authViewModel.userIdentifier, !userIdentifier.isEmpty else {
            print("User identifier is not available.")
            return
        }

        let database = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(format: "userIdentifier == %@", userIdentifier)
        let query = CKQuery(recordType: "PersonalData", predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { records, error in
            guard let personalDataRecord = records?.first else {
                print("PersonalData record not found for userIdentifier: \(userIdentifier). Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let packID = packID {
                let reference = CKRecord.Reference(recordID: CKRecord.ID(recordName: packID.uuidString), action: .none)
                personalDataRecord["CurrentPack"] = reference
            } else {
                personalDataRecord["CurrentPack"] = nil
            }
            
            database.save(personalDataRecord) { _, error in
                if let error = error {
                    print("Failed to update PersonalData with current pack: \(error.localizedDescription)")
                } else {
                    print("PersonalData updated successfully with the current pack for userIdentifier: \(userIdentifier).")
                }
            }
        }
    }




    func fetchPacks() {
        guard let userIdentifier = authViewModel.userIdentifier, !userIdentifier.isEmpty else {
            print("User identifier is not available.")
            return
        }

        let database = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(format: "userIdentifier == %@", userIdentifier)
        let query = CKQuery(recordType: "PersonalData", predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Failed to fetch PersonalData record: \(error.localizedDescription)")
                return
            }
            
            guard let personalDataRecord = records?.first else {
                print("PersonalData record not found for userIdentifier: \(userIdentifier)")
                return
            }
            
            guard let allPacksRefs = personalDataRecord["AllPacks"] as? [CKRecord.Reference] else {
                print("AllPacks field is missing or empty in PersonalData record")
                return
            }
            
            let packIDs = allPacksRefs.map { $0.recordID }
            self.fetchWorkoutPacks(by: packIDs)
        }
    }

    private func fetchWorkoutPacks(by packIDs: [CKRecord.ID]) {
        let database = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(format: "recordID IN %@", packIDs)
        let query = CKQuery(recordType: "WorkoutPacks", predicate: predicate)

        database.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to fetch WorkoutPacks: \(error.localizedDescription)")
                    return
                }

                guard let records = records, !records.isEmpty else {
                    print("No WorkoutPacks records found for provided packIDs")
                    return
                }

                print("Successfully fetched WorkoutPacks records: \(records)")

                self.packs = records.compactMap { record in
                    guard let packIDList = record["PackID"] as? [String], let packIDString = packIDList.first else {
                        print("PackID is missing or not a string in record: \(record)")
                        return nil
                    }
                    return UUID(uuidString: packIDString)
                }

                print("Updated packs array: \(self.packs)")
            }
        }
    }


}

struct WorkoutPacks_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutPacks()
            .environmentObject(AuthViewModel())

    }
}
