//
//  TodaysWorkout.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/5/24.
//
import SwiftUI
import CloudKit

struct TodaysWorkout: View {
    @State private var dayName: String = "Fetching Workout..."  // Placeholder text
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationLink(destination: NameOfDay()) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 41/255, green: 41/255, blue: 41/255))
                .frame(height: 70)
                .shadow(radius: 5)
                .overlay(
                    HStack(spacing: 15) {
                        Circle()
                            .padding(.leading, 10.0)
                            .foregroundColor(Color(red: 0.07, green: 0.69, blue: 0.951))
                            .frame(width: 50, height: 50)
                            .opacity(0.5)
                        Spacer()
                           
                        VStack {
                            Text("\(dayName)!")
                                .foregroundColor(Color.white)
                                .font(.system(size: 25))
                                .bold()
                            Text("Get Started")
                                .foregroundColor(Color.gray)
                                .font(.system(size: 15))
                        }
                       
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .foregroundColor(Color.gray)
                            .frame(width: 50, height: 50)
                            .imageScale(.large)
                    }
                )
        }
        .padding(.horizontal, 15)
        .onAppear(perform: fetchDayName)
    }

    private func fetchDayName() {
        let container = CKContainer.default()
        let publicDB = container.publicCloudDatabase

        guard let userIdentifier = authViewModel.userIdentifier, !userIdentifier.isEmpty else {
            self.dayName = "User identifier not available"
            return
        }

        let predicate = NSPredicate(format: "userIdentifier == %@", userIdentifier)
        let query = CKQuery(recordType: "PersonalData", predicate: predicate)

        publicDB.perform(query, inZoneWith: nil) { (records, error) in


            DispatchQueue.main.async {
                if let error = error {
                    self.dayName = "Error: \(error.localizedDescription)"
                    return
                }

                guard let personalDataRecord = records?.first,
                      let currentPackReference = personalDataRecord["CurrentPack"] as? CKRecord.Reference else {
                    self.dayName = "Current Pack not found"
                    return
                }

                let packDaysPredicate = NSPredicate(format: "PackID == %@", currentPackReference.recordID)
                let packDaysQuery = CKQuery(recordType: "PackDay", predicate: packDaysPredicate)

                publicDB.perform(packDaysQuery, inZoneWith: nil) { (packDaysRecords, packDaysError) in
                    if let packDaysError = packDaysError {
                        self.dayName = "Error: \(packDaysError.localizedDescription)"
                        return
                    }

                    guard let packDaysRecord = packDaysRecords?.first,
                          let fetchedDayName = packDaysRecord["DayName"] as? String else {
                        self.dayName = "Day name not found"
                        return
                    }

                    self.dayName = fetchedDayName
                }
            }
        }
    }
}

// Dummy preview provider
struct TodaysWorkout_Previews: PreviewProvider {
    static var previews: some View {
        TodaysWorkout().environmentObject(AuthViewModel())
    }
}
