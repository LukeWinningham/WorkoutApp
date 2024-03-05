//
//  SwiftUIView.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 1/30/24.
//


import SwiftUI
import CloudKit

class DayManager: ObservableObject {
    @Published var days: [(id: UUID, name: String, order: Int)] = []

    func fetchDays(currentPackID: UUID?, completion: @escaping () -> Void = {}) {
        guard let currentPackID = currentPackID else {
            print("fetchDays was called without a currentPackID.")
            return
        }
        let database = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(format: "PackID == %@", CKRecord.ID(recordName: currentPackID.uuidString))
        let query = CKQuery(recordType: "PackDay", predicate: predicate)

        database.perform(query, inZoneWith: nil) { [weak self] records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching days: \(error.localizedDescription)")
                } else if let records = records {
                    print("Successfully fetched \(records.count) days.")
                    self?.days = records.compactMap { record in
                        guard let dayName = record["DayName"] as? String,
                              let dayID = record["DayID"] as? String,
                              let order = record["Order"] as? Int,
                              let uuid = UUID(uuidString: dayID) else {
                            print("Error mapping record to day tuple.")
                            return nil
                        }
                        return (id: uuid, name: dayName, order: order)
                    }
                    completion()
                } else {
                    print("No records returned while fetching days.")
                }
            }
        }
    }


    func triggerUpdate() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}

struct AddView: View {
    @StateObject private var dayManager = DayManager()
    @State private var isTextFieldContainerVisible = false
    @State private var newItemName: String = ""
    @State private var currentPackID: UUID?
    @State private var showingWorkoutPacks = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    let maxCharacterCount = 12

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 18/255, green: 18/255, blue: 18/255).edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        // Dismiss the keyboard and hide the text field container
                        hideTextFieldContainer()
                    }
                
                VStack {
                    headerView
                    daysListView
                    Spacer() // This will push everything to the top
                }
                .onAppear(perform: fetchCurrentPackID)
                
                // Positioned at the bottom right
                if isTextFieldContainerVisible {
                    textFieldContainerView
                } else {
                    // Position the plus button at the bottom right
                                  VStack {
                                      Spacer() // Pushes the button to the bottom
                                      HStack {
                                          Spacer() // Pushes the button to the right
                                          plusButton
                                              .padding(20) // Adds space around the button from the edges of the screen
                                      }
                                  }
                              }
            }
            .sheet(isPresented: $showingWorkoutPacks) {
                WorkoutPacks()
            }
        }
    }
    private func hideTextFieldContainer() {
        isTextFieldContainerVisible = false
        // Hide the keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    var headerView: some View {
        HStack {
            // Profile picture on the far left as a navigation link
        /*
            NavigationLink(destination: ProfileView()) {
                if let profileImage = authViewModel.profilePicture {
                    Image(uiImage: profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30.0, height: 30.0) // Adjust size as needed
                        .clipShape(Circle())
                } else {
                    Image("person.crop.circle") // Use your placeholder image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30.0, height: 30.0) // Adjust size as needed
                        .clipShape(Circle())
                }
            }
            .padding(.leading, 10)
            */


            Text("Add A Day")
                .font(.title)
                .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                .padding(.trailing, 25)
                .bold()

            Spacer() // Another spacer after the text to ensure it stays centered

            workoutPackButton
                .padding(.trailing, 10)

        }
        .padding()
        .background(Color(red: 18/255, green: 18/255, blue: 18/255))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)

    }

    var textFieldContainerView: some View {
        HStack {
            Circle().frame(width: 40, height: 40).foregroundColor(Color.blue).shadow(radius: 3)
            TextField("Enter Day Name", text: $newItemName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .foregroundColor(Color.white)
                .onChange(of: newItemName) { newValue in
                    if newValue.count > maxCharacterCount {
                        newItemName = String(newValue.prefix(maxCharacterCount))
                    }
                }
            Button("Save") {
                addDay(withName: newItemName)
            }
            .disabled(newItemName.isEmpty || currentPackID == nil)
            .padding(.trailing)
            .foregroundColor(Color.white)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10)
            .fill(Color(red: 41/255, green: 41/255, blue: 41/255))
            .shadow(radius: 3))
        .padding()
        .padding(.bottom, 420)
    }

    

    var daysListView: some View {
        ScrollView {
            VStack {
                ForEach(dayManager.days, id: \.id) { day in
                    NavigationLink(destination: DayDetailView(dayID: day.id, dayName: day.name)) {
                        VStack {
                            HStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 41/255, green: 41/255, blue: 41/255))
                                    .frame(height: 70)
                                    .overlay(   HStack(spacing: 15) {
                                        Circle()
                                            .padding(.leading, 10.0)
                                            .foregroundColor(Color(red: 0.07, green: 0.69, blue: 0.951))
                                            .frame(width: 50, height: 50)
                                            .opacity(0.5)
                                        Spacer()
                                           
                                        Text(day.name)
                                            .font(.system(size: 25))
                                            .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                                       
                                        Spacer()
                                        Image(systemName: "chevron.forward")
                                            .foregroundColor(Color.gray)
                                            .frame(width: 50, height: 50)
                                            .imageScale(.large)
                                    }
                                )
                        }
                            .padding(.horizontal)
                            .padding(.top, 5)
                          

                        }
                      

                    }
                }
            }
        }
    }


    var workoutPackButton: some View {
        Button(action: {
            showingWorkoutPacks = true
        }) {
            Image(systemName: "figure.run.square.stack")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(Color.red)
                .padding()
        }
    }

    private func fetchCurrentPackID() {
        guard let userIdentifier = UserDefaults.standard.string(forKey: "userIdentifier") else {
            print("User identifier is not available.")
            return
        }

        let database = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(format: "userIdentifier == %@", userIdentifier)
        let query = CKQuery(recordType: "PersonalData", predicate: predicate)

        database.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching current pack ID: \(error.localizedDescription)")
                } else if let record = records?.first, let packReference = record["CurrentPack"] as? CKRecord.Reference {
                    self.currentPackID = UUID(uuidString: packReference.recordID.recordName)
                    print("Successfully fetched current pack ID: \(String(describing: self.currentPackID))")
                    self.dayManager.fetchDays(currentPackID: self.currentPackID)
                } else {
                    print("No PersonalData record found for userIdentifier: \(userIdentifier) or missing 'CurrentPack' field.")
                }
            }
        }
    }



    private func addDay(withName name: String) {
        guard !name.isEmpty, let currentPackID = currentPackID else {
            print("Day name is empty or current pack ID is nil.")
            return
        }

        let database = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(format: "PackID == %@", CKRecord.ID(recordName: currentPackID.uuidString))
        let query = CKQuery(recordType: "PackDay", predicate: predicate)

        database.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching days: \(error.localizedDescription)")
                } else {
                    let existingOrderNumbers = records?.compactMap { $0["Order"] as? Int } ?? []
                    let nextOrderNumber = (existingOrderNumbers.max() ?? 0) + 1

                    let newDayRecord = CKRecord(recordType: "PackDay")
                    newDayRecord["DayName"] = name
                    newDayRecord["PackID"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: currentPackID.uuidString), action: .none)
                    let dayID = UUID()
                    newDayRecord["DayID"] = dayID.uuidString
                    newDayRecord["Order"] = nextOrderNumber

                    database.save(newDayRecord) { record, error in
                        DispatchQueue.main.async {
                            if let error = error {
                                print("Error saving new day: \(error.localizedDescription)")
                            } else {
                                self.newItemName = ""
                                self.isTextFieldContainerVisible = false
                                self.updateNextWorkoutWithDay(dayRecord: newDayRecord, order: nextOrderNumber)
                                self.dayManager.fetchDays(currentPackID: self.currentPackID) {
                                    self.dayManager.triggerUpdate()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func updateNextWorkoutWithDay(dayRecord: CKRecord, order: Int) {
        guard let currentPackID = self.currentPackID else {
            print("Current pack ID is not available.")
            return
        }

        let database = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(format: "recordID == %@", CKRecord.ID(recordName: currentPackID.uuidString))
        let query = CKQuery(recordType: "Pack", predicate: predicate) // Assuming your Pack record type is "Pack"

        database.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching Pack record: \(error.localizedDescription)")
                } else if let packRecord = records?.first {
                    var nextWorkoutList: [CKRecord.Reference] = packRecord["NextWorkout"] as? [CKRecord.Reference] ?? []
                    nextWorkoutList.append(CKRecord.Reference(record: dayRecord, action: .none))
                    packRecord["NextWorkout"] = nextWorkoutList.sorted(by: { $0.recordID.recordName < $1.recordID.recordName }) // Sort if necessary

                    database.save(packRecord) { record, error in
                        DispatchQueue.main.async {
                            if let error = error {
                                print("Error updating Pack with new day: \(error.localizedDescription)")
                            } else {
                                print("Pack updated successfully with new day.")
                                // Trigger any necessary UI updates
                            }
                        }
                    }
                }
            }
        }
    }



    var plusButton: some View {
            Button(action: { isTextFieldContainerVisible.toggle() }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60) // Adjust size as needed
                    .foregroundColor(Color(red: 0/255, green: 211/255, blue: 255/255))
                    .background(Color.black.opacity(0.5)) // Optional: add a slight background to improve contrast
                    .clipShape(Circle())
                    .shadow(radius: 10) // Optional: add a shadow for a more distinct appearance
            }
        }
    }


struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView().environmentObject(AuthViewModel())
    }
}
