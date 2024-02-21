//
//  SwiftUIView.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 1/30/24.
//


import SwiftUI
import CloudKit

class DayManager: ObservableObject {
    @Published var days: [(id: UUID, name: String)] = []

    func fetchDays(currentPackID: UUID?, completion: @escaping () -> Void = {}) {
        guard let currentPackID = currentPackID else { return }
        let database = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(format: "PackID == %@", CKRecord.ID(recordName: currentPackID.uuidString))
        let query = CKQuery(recordType: "PackDay", predicate: predicate)

        database.perform(query, inZoneWith: nil) { [weak self] records, error in
            DispatchQueue.main.async {
                if let records = records {
                    self?.days = records.compactMap { record in
                        if let dayName = record["DayName"] as? String, let dayID = record["DayID"] as? String {
                            return (UUID(uuidString: dayID)!, dayName)
                        }
                        return nil
                    }
                    completion() // Call the completion handler
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

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color(red: 18/255, green: 18/255, blue: 18/255).edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        // Dismiss the keyboard and hide the text field container
                        hideTextFieldContainer()
                    }
                VStack {
                    headerView
                    daysListView
                    if isTextFieldContainerVisible {
                        textFieldContainerView     

                    }
                }
                .onAppear(perform: fetchCurrentPackID)
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
            workoutPackButton
            Spacer()
            Text("Add A Day").font(.title).foregroundColor(Color.white)
            Spacer()
            Button(action: { isTextFieldContainerVisible.toggle() }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(red: 0/255, green: 211/255, blue: 255/255))
                    .padding()
            }
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
                                    .overlay(
                                        HStack {
                                            Circle()
                                                .frame(width: 50, height: 40)
                                                .shadow(radius: 5)
                                                .foregroundColor(Color(red: 0.07, green: 0.69, blue: 0.951))
                                                .opacity(1)
                                            
                                            Text(day.name)
                                                .font(.system(size: 20))
                                                .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                                            
                                            Spacer()
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
                .frame(width: 20, height: 20)
                .foregroundColor(Color.red)
                .padding()
        }
    }

    private func fetchCurrentPackID() {
        let database = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(value: true) // Adjust according to your needs
        let query = CKQuery(recordType: "PersonalData", predicate: predicate)

        database.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching current pack ID: \(error.localizedDescription)")
                } else if let record = records?.first, let packReference = record["CurrentPack"] as? CKRecord.Reference {
                    self.currentPackID = UUID(uuidString: packReference.recordID.recordName)
                    self.dayManager.fetchDays(currentPackID: self.currentPackID)
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
        let newDayRecord = CKRecord(recordType: "PackDay")
        newDayRecord["DayName"] = name
        newDayRecord["PackID"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: currentPackID.uuidString), action: .none)

        // Generate a new UUID for DayID and store its string representation in the record
        let dayID = UUID()
        newDayRecord["DayID"] = dayID.uuidString

        database.save(newDayRecord) { [self] record, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error saving new day: \(error.localizedDescription)")
                } else {
                    self.newItemName = ""
                    self.isTextFieldContainerVisible = false
                    self.dayManager.fetchDays(currentPackID: self.currentPackID) {
                        self.dayManager.triggerUpdate() // Force update
                    }
                }
            }
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
    }
}
