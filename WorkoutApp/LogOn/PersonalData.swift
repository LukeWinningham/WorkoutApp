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
    @State private var showingAlert = false
    @State private var alertMessage: String = ""
    @State private var selection: Int = 0
    @State private var showWelcome: Bool = true
    @State private var showingImagePicker: Bool = false
    @State private var inputImage: UIImage?

    let maxCharacterCount: Int = 12

    var body: some View {
        ZStack {
            Color(red: 18/255, green: 18/255, blue: 18/255).edgesIgnoringSafeArea(.all)
            VStack {

                Spacer()

                if showWelcome {
                    Text("Welcome To Amson")
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .bold()
                        .foregroundColor(Color.white)
                        .opacity(showWelcome ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showWelcome = false
                                }
                            }
                        }
                        .padding(.horizontal)
                } else {
                    HStack {
                        Spacer() // Pushes the "Save" button to the right
                        Button("Save", action: saveToCloudKit)
                            .padding()
                            .background(Color.clear)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 140)
                    VStack(spacing: 20){
                        Text("What should we call you?")
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .bold()
                            .foregroundColor(Color.white)
                            .padding(.bottom, 20)
                        
                        VStack(spacing: 15) {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 70)
                                .overlay(
                                    TextField("Display Name", text: $firstName)
                                        .padding(.horizontal)
                                        .foregroundColor(.white)
                                        .onChange(of: firstName) { newValue in
                                            if newValue.count > maxCharacterCount {
                                                firstName = String(newValue.prefix(maxCharacterCount))
                                            }
                                        }
                                )
                                .foregroundColor(Color.black)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 70)
                                .overlay(
                                    TextField("Username", text: $username)
                                        .padding(.horizontal)
                                        .foregroundColor(.white)
                                        .onChange(of: username) { newValue in
                                            if newValue.count > maxCharacterCount {
                                                username = String(newValue.prefix(maxCharacterCount))
                                            }
                                        }
                                )
                                .foregroundColor(Color.black)
                        }
                        
                        VStack(spacing: 3) {
                            Text("Are you currently")
                                .font(.title)
                                .multilineTextAlignment(.center)
                                .bold()
                                .foregroundColor(Color.white)
                            HStack {
                                PillButton(text: "Losing", isSelected: selection == 0) { selection = 0 }
                                PillButton(text: "Maintaining", isSelected: selection == 1) { selection = 1 }
                                PillButton(text: "Bulking", isSelected: selection == 2) { selection = 2 }
                            }
                            .padding(.top, 20)
                            .padding(.horizontal)
                            
                        }
                        Spacer()
                    }
                        .padding(.horizontal)


                }


                Spacer()
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(selectedImage: $inputImage)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }
        authViewModel.saveProfilePicture(image: inputImage)
    }


    func checkUsernameUnique(username: String, completion: @escaping (Bool) -> Void) {
        let container = CKContainer.default()
        let database = container.publicCloudDatabase
        let predicate = NSPredicate(format: "username == %@", username)
        let query = CKQuery(recordType: "PersonalData", predicate: predicate)
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["username"]
        queryOperation.resultsLimit = 1
        
        var isUnique = true
        queryOperation.recordMatchedBlock = { (recordID, result) in
            switch result {
            case .success(_):
                isUnique = false
            case .failure(let error):
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
        guard !firstName.isEmpty, !username.isEmpty else {
            alertMessage = "First name and username cannot be empty."
            showingAlert = true
            return
        }
        
        checkUsernameUnique(username: username) { isUnique in
            guard isUnique else {
                self.alertMessage = "Username is already taken. Please choose another one."
                self.showingAlert = true
                return
            }
            
            guard let userIdentifier = self.authViewModel.userIdentifier else { return }
            
            let container = CKContainer.default()
            let database = container.publicCloudDatabase
            
            let profileRecord = CKRecord(recordType: "PersonalData")
            profileRecord["firstName"] = self.firstName
            profileRecord["username"] = self.username
            profileRecord["goal"] = self.goalString(from: self.selection)

            // Set userIdentifier as a String, not as a CKRecord.Reference
            profileRecord["userIdentifier"] = userIdentifier
            
            database.save(profileRecord) { record, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.alertMessage = "Error saving profile: \(error.localizedDescription)"
                        self.showingAlert = true
                    } else {
                        self.alertMessage = "Profile saved successfully."
                        self.showingAlert = true
                        self.authViewModel.completeProfile()
                    }
                }
            }
        }
    }


    // Helper function to convert the selection integer to a corresponding goal string
    func goalString(from selection: Int) -> String {
        switch selection {
        case 0: return "Losing"
        case 1: return "Maintaining"
        case 2: return "Bulking"
        default: return "Unknown"
        }
    }

    
    struct PillButton: View {
        var text: String
        var isSelected: Bool
        var action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(text)
                    .font(.subheadline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .foregroundColor(.white)
                    .background(isSelected ? Color.blue : Color.gray)
                    .cornerRadius(20)
            }
        }
    }
}


struct PersonalData_Previews: PreviewProvider {
    static var previews: some View {
        PersonalData()
    }
}
