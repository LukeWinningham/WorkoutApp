//
//  PersonalData.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/7/24.
//
import SwiftUI
import CloudKit
import Combine

struct PersonalData: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var firstName: String = ""
    @State private var username: String = ""
    @State private var feet: Int = 5
    @State private var inches: Int = 6
    @State private var weight: Int = 150
    @State private var birthday = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            Color(red: 217/255, green: 217/255, blue: 217/255).edgesIgnoringSafeArea(.all)
            VStack(spacing: 50) {
                VStack {
                    Text("Let's Fill Out Your Profile!")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .bold()
                        .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.199))
                }
                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 70)
                        .overlay(
                            TextField("First Name", text: $firstName)
                                .padding(.horizontal)
                        )
                        .foregroundColor(/*@START_MENU_TOKEN@*/Color.gray/*@END_MENU_TOKEN@*/)

                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 70)
                        .overlay(
                            TextField("Username", text: $username)
                                .padding(.horizontal)
                        )
                        .foregroundColor(/*@START_MENU_TOKEN@*/Color.gray/*@END_MENU_TOKEN@*/)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 70)
                        .overlay(
                            HStack {
                                Text("Height")
                                    .foregroundColor(Color.black)
                                Spacer()
                                Picker("Height", selection: $feet) {
                                    ForEach(3..<8) { feet in
                                        ForEach(0..<12) { inches in
                                            Text("\(feet) ft \(inches) in").tag([feet, inches])
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        )
                        .foregroundColor(/*@START_MENU_TOKEN@*/Color.gray/*@END_MENU_TOKEN@*/)

                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 70)
                        .overlay(
                            HStack {
                                Text("Weight")
                                    .foregroundColor(Color.black)
                                Spacer()
                                Picker("Weight", selection: $weight) {
                                    ForEach(50..<400) { weight in
                                        Text("\(weight) lbs").tag(weight)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        )
                        .foregroundColor(/*@START_MENU_TOKEN@*/Color.gray/*@END_MENU_TOKEN@*/)

                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 70)
                        .overlay(
                            DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                                .padding(.horizontal)
                        )
                        .foregroundColor(/*@START_MENU_TOKEN@*/Color.gray/*@END_MENU_TOKEN@*/)

                }
                Button("Save and Next!", action: saveToCloudKit)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.067, green: 0.69, blue: 0.951), Color(hue: 1.0, saturation: 0.251, brightness: 0.675)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
    func checkUsernameUnique(username: String, completion: @escaping (Bool) -> Void) {
        let container = CKContainer.default()
        let database = container.publicCloudDatabase
        let predicate = NSPredicate(format: "username == %@", username)
        let query = CKQuery(recordType: "PersonalData", predicate: predicate)

        let queryOperation = CKQueryOperation(query: query)
        // Optionally, specify desired keys if you want to limit the fields returned by the query
        queryOperation.desiredKeys = ["username"]
        // You can also limit the number of results returned
        queryOperation.resultsLimit = 1

        var isUnique = true
        queryOperation.recordMatchedBlock = { (recordID, result) in
            switch result {
            case .success(_):
                // If we successfully match any record, the username is not unique
                isUnique = false
            case .failure(let error):
                // Handle each record error if needed
                print("Record fetch error: \(error.localizedDescription)")
            }
        }

        queryOperation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    completion(isUnique)
                case .failure(let error):
                    print("Query completion error: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }

        database.add(queryOperation)
    }


    func saveToCloudKit() {
        guard let userIdentifier = authViewModel.userIdentifier else { return }

        let container = CKContainer.default()
        let database = container.publicCloudDatabase

        let profileRecord = CKRecord(recordType: "PersonalData")
        profileRecord["firstName"] = firstName
        profileRecord["username"] = username
        profileRecord["feet"] = feet
        profileRecord["inches"] = inches
        profileRecord["weight"] = weight
        profileRecord["birthday"] = birthday
        profileRecord["userIdentifier"] = userIdentifier

        database.save(profileRecord) { (record, error) in
            if let error = error {
                print("Error saving profile to CloudKit: \(error.localizedDescription)")
            } else {
                print("Profile saved to CloudKit successfully.")
                DispatchQueue.main.async {
                    self.authViewModel.completeProfile()
                }
            }
        }
    }
}



struct PersonalData_Previews: PreviewProvider {
    static var previews: some View {
        PersonalData()
    }
}

