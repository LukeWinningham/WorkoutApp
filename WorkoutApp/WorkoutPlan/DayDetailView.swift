//
//  WorkoutPlanDetails.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/9/24.
//
import CloudKit
import SwiftUI
import Combine

class DayExercisesViewModel: ObservableObject {
    @Published var exercises: [CKRecord] = []
    
    func fetchExercises(forDayID dayID: UUID) {
        let database = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(format: "DayID == %@", CKRecord.ID(recordName: dayID.uuidString))
        let query = CKQuery(recordType: "PackExercises", predicate: predicate)

        database.perform(query, inZoneWith: nil) { [weak self] (records, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching exercises for day ID \(dayID): \(error.localizedDescription)")
                    return
                }

                guard let records = records else {
                    print("No records found for day ID \(dayID)")
                    return
                }

                self?.exercises = records
            }
        }
    }
}

struct DayDetailView: View {
    @StateObject private var viewModel = DayExercisesViewModel()
    var dayID: UUID
    var dayName: String
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
                    .font(.title)
                    .foregroundColor(Color.white)
                    .padding()

                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.exercises, id: \.recordID) { exercise in
                            HStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 41/255, green: 41/255, blue: 41/255))
                                    .frame(height: 70)
                                    .shadow(radius: 5)
                                    .overlay(
                                        HStack(spacing: 15) {
                                            
                                            ZStack {
                                                // Larger blue circle as the background
                                                Circle()
                                                    .frame(width: 50, height: 50) // Size of the outer circle
                                                    .foregroundColor(Color(red: 0/255, green: 117/255, blue: 255/255)) // Blue background for the outer circle
                                                
                                                // Inner ZStack with the smaller circle, white stroke, and image
                                                ZStack {
                                                    Circle()
                                                        .frame(width: 50, height: 50) // Smaller circle size for the inner content
                                                        .foregroundColor(Color(red: 0/255, green: 117/255, blue: 255/255)) // Blue background for the inner circle

                                                    Circle()
                                                        .stroke(Color.white, lineWidth: 4) // White stroke for the inner circle
                                                        .frame(width: 50, height: 50) // Matching size with the inner blue circle

                                                    // Conditional statement to choose the image
                                                    if let _ = exercise["Time"] as? Int {
                                                        // Time-based exercise image
                                                        Image(systemName: "figure.run")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 30, height: 30) // Image size for the inner content
                                                            .foregroundColor(Color(red: 18/255, green: 18/255, blue: 18/255)) // Image color for the inner content
                                                    } else {
                                                        // Other exercises image
                                                        Image(systemName: "figure.strengthtraining.traditional")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 30, height: 30) // Image size for the inner content
                                                            .foregroundColor(Color(red: 18/255, green: 18/255, blue: 18/255)) // Image color for the inner content
                                                    }
                                                }
                                            }
                                            
                                        
                                            VStack(alignment: .leading) {
                                                Text(exercise["ChosenExercise"] as? String ?? "Unknown Exercise")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                                                
                                                // Assuming you have "Sets" and "Reps" fields in your CKRecord
                                                if let sets = exercise["Sets"] as? Int {
                                                    Text("\(sets) Sets")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                                }
                                                else if let time = exercise["Time"] as? Int {
                                                    Text("Time: \(time) minutes")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                                }
                                            }
                                            Spacer()
                                        }
                                            .padding(.leading, 20) // Add leading padding to push content to the right
                                    )
                                    
                            }
                            .padding(.horizontal)
                            .padding(.top, 5)
                           

                        }
                    }
                }


                Spacer()

                NavigationLink(destination: AllExercises(dayID: CKRecord.ID(recordName: dayID.uuidString))) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color(red: 0/255, green: 211/255, blue: 255/255))
                        .padding()
                }

            }
        }
        .onAppear {
            viewModel.fetchExercises(forDayID: dayID)
        }
    }
}

struct DayDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DayDetailView(dayID: UUID(), dayName: "Monday")
    }
}
