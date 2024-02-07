//
//  PersonalData.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/7/24.
//
import SwiftUI
import CloudKit

struct PersonalData: View {
    @State private var firstName: String = ""
    @State private var username: String = ""
    @State private var feet: Int = 5 // Default feet
    @State private var inches: Int = 6 // Default inches
    @State private var weight: Int = 150 // Default weight in lbs
    @State private var birthday = Date()

    var body: some View {
        ZStack {
            Color(red: 217/255, green: 217/255, blue: 217/255).edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Text("Let's Fill Out Your Profile!")
                    .font(.title)
                    .padding()
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .frame(height: 70)
                    .overlay(
                        TextField("First Name", text: $firstName)
                            .padding(.horizontal)
                    )
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .frame(height: 70)
                    .overlay(
                        TextField("Username", text: $username)
                            .padding(.horizontal)
                    )
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .frame(height: 70)
                    .overlay(
                        HStack{
                            Text("Height")
                            Spacer()
                            Picker("Height", selection: $feet) {
                                ForEach(3..<8) { feet in // Range of feet
                                    ForEach(0..<12) { inches in // Range of inches
                                        Text("\(feet) ft \(inches) in").tag([feet, inches])
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    )
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .frame(height: 70)
                    .overlay(
                        HStack{
                            Text("Weight")
                            Spacer()
                            Picker("Weight", selection: $weight) {
                                ForEach(50..<400) { weight in // Range of weight in lbs
                                    Text("\(weight) lbs").tag(weight)
                                }
                            }
                        }
                        .padding(.horizontal)
                    )
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .frame(height: 70)
                    .overlay(
                        DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                            .padding(.horizontal)
                    )
    
                Button("Save and Next!", action: saveToCloudKit)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.067, green: 0.69, blue: 0.951), Color(hue: 1.0, saturation: 0.251, brightness: 0.675)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                
            }
            .padding(.horizontal)
        }
    }
    
    func saveToCloudKit() {
        let container = CKContainer.default()
        let database = container.privateCloudDatabase
        
        let profileRecord = CKRecord(recordType: "UserProfile")
        profileRecord["firstName"] = firstName as CKRecordValue
        profileRecord["username"] = username as CKRecordValue
        profileRecord["feet"] = feet as CKRecordValue
        profileRecord["inches"] = inches as CKRecordValue
        profileRecord["weight"] = weight as CKRecordValue
        profileRecord["birthday"] = birthday as CKRecordValue
        
        database.save(profileRecord) { (record, error) in
            if let error = error {
                print("Error saving profile to CloudKit: \(error.localizedDescription)")
            } else {
                print("Profile saved to CloudKit successfully.")
            }
        }
    }
}

struct PersonalData_Previews: PreviewProvider {
    static var previews: some View {
        PersonalData()
    }
}
