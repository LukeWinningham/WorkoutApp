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

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
}

struct WorkoutPacks: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var packs = [PackData]()
    @State private var showingAddPackView = false

    let packWidth: CGFloat = 400
    let packHeight: CGFloat = 700
    let spacing: CGFloat = 16

    var body: some View {
         NavigationView {
             ZStack(alignment: .top) {
                 Color(red: 18/255, green: 18/255, blue: 18/255).edgesIgnoringSafeArea(.all)

                 VStack {
                     headerView
                     Spacer()
                     packsCarousel
                 }

                 // Add button positioned at the bottom right
                 VStack {
                     Spacer() // Pushes everything above to the top
                     HStack {
                         Spacer() // Pushes the button to the right
                         addButton
                             .padding(20) // Adds space around the button from the edges of the screen
                     }
                 }
             }
             .onAppear {
                 
                 fetchPacks()
                 fetchCurrentPackID() // Fetch the current pack ID when the view appears

             }
             .sheet(isPresented: $showingAddPackView) {
                 AddPackView(isPresented: $showingAddPackView, onSave: { packName, selectedImage in
                     addPack(name: packName, image: selectedImage)
                 })
             }
         }
     }

     var addButton: some View {
         Button(action: {
             showingAddPackView = true
         }) {
             Image(systemName: "plus.circle.fill")
                 .resizable()
                 .frame(width: 60, height: 60) // Adjust the size as needed
                 .foregroundColor(Color(red: 0/255, green: 211/255, blue: 255/255))
                 .background(Color.black.opacity(0.5)) // Optional: adds a slight background to improve contrast
                 .clipShape(Circle())
                 .shadow(radius: 10) // Optional: adds a shadow for a more distinct appearance
         }
     }
    var headerView: some View {
        HStack {
            // Left-aligned chevron icon
            Image(systemName: "chevron.down")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundColor(Color.white)

            Spacer() // Pushes the chevron to the left and title to the center

            // Centered title
            Text("Workout Packs")
                .font(.title)
                .foregroundColor(Color.white)

            Spacer() // Maintains the center alignment of the title

            // Invisible spacer to balance the chevron icon and maintain the title's center alignment
            Image(systemName: "chevron.down")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundColor(Color.clear) // Make this icon invisible
        }
        .padding()
        .background(Color(red: 18/255, green: 18/255, blue: 18/255))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }



    var packsCarousel: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    ForEach(packs, id: \.id) { packData in
                        workoutPackView(packData: packData)
                            .frame(width: packWidth, height: packHeight)
                            .padding(.horizontal, (geometry.size.width - packWidth) / 2)
                            .onTapGesture {
                                // Handle pack selection here
                                authViewModel.selectedPackID = packData.id
                            }
                    }
                }
            }
            .frame(height: packHeight)
        }
    }
    func fetchCurrentPackID() {
        // Fetch the current pack ID from UserDefaults
        if let currentPackID = UserDefaults.standard.string(forKey: "CurrentPack"), let uuid = UUID(uuidString: currentPackID) {
            authViewModel.selectedPackID = uuid
        } else {
            // Handle the case where there is no current pack ID saved
        }
    }
    func workoutPackView(packData: PackData) -> some View {
        VStack(alignment: .center) {
            ZStack{
  
                Text(packData.packInfo) // Displaying the pack info
                    .font(.title)
                    .foregroundColor(Color.white)
                    
                   
                HStack{
                    Spacer()
                    Button(action: {
                    }) {
                        Image(systemName: "pencil")
                        // Styling for the button
                    }



                }
                
            }
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.clear) // Fill color is clear to allow the image to be seen
                .frame(width: 360, height: 600) // Set the frame to the specified dimensions
                .overlay(
                    Image(uiImage: packData.image ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fill) // Fill the frame while maintaining aspect ratio
                        .clipped() // Clip the overflowing parts of the image
                    
                )
                .cornerRadius(25) // Apply corner radius to the RoundedRectangle
                .overlay(
                    Group {
                        if authViewModel.selectedPackID == packData.id {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white.opacity(0.5))
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(Color.black)
                                )
                                
                        }
                    }
                )
            
        }
        .onTapGesture {
            // Handle pack selection here
            authViewModel.selectedPackID = packData.id
            // Update CurrentPack in PersonalData
            updateCurrentPackInPersonalData(packID: packData.id)
        }
    }

    func updateCurrentPackInPersonalData(packID: UUID) {
        guard let userIdentifier = authViewModel.userIdentifier, !userIdentifier.isEmpty else {
            print("User identifier is not available.")
            return
        }

        let database = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(format: "userIdentifier == %@", userIdentifier)
        let query = CKQuery(recordType: "PersonalData", predicate: predicate)

        database.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to fetch PersonalData record: \(error.localizedDescription)")
                    return
                }

                guard let personalDataRecord = records?.first else {
                    print("PersonalData record not found for userIdentifier: \(userIdentifier)")
                    return
                }
                UserDefaults.standard.set(packID.uuidString, forKey: "CurrentPack")

                // Update CurrentPack attribute in PersonalData
                personalDataRecord["CurrentPack"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: packID.uuidString), action: .none)

                database.save(personalDataRecord) { savedRecord, saveError in
                    DispatchQueue.main.async {
                        if let saveError = saveError {
                            print("Failed to update CurrentPack in PersonalData: \(saveError.localizedDescription)")
                        } else {
                            print("CurrentPack updated successfully.")
                        }
                    }
                }
            }
        }
    }


    func addPack(name: String, image: UIImage?) {
        let packID = UUID()
        let newPackRecord = CKRecord(recordType: "WorkoutPacks")
        newPackRecord["PackID"] = [packID.uuidString]
        newPackRecord["PackInfo"] = [name] // Storing the pack name
        newPackRecord["username"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: authViewModel.userIdentifier ?? ""), action: .none) // Referencing the username

        if let image = image, let asset = convertImageToCKAsset(image: image) {
            newPackRecord["PackImage"] = asset // Storing the image as an asset
        }

        let database = CKContainer.default().publicCloudDatabase
        database.save(newPackRecord) { record, error in
            if let error = error {
                print("Error saving new pack: \(error.localizedDescription)")
            } else {
                print("Pack saved successfully.")
                self.fetchPacks()
            }
        }
    }

    func convertImageToCKAsset(image: UIImage) -> CKAsset? {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return nil }

        let temporaryDirectory = FileManager.default.temporaryDirectory
        let fileURL = temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")

        do {
            try imageData.write(to: fileURL)
            return CKAsset(fileURL: fileURL)
        } catch {
            print("Error writing image data to file: \(error)")
            return nil
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
            DispatchQueue.main.async {
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

                self.packs = records.compactMap { record in
                    guard let packIDList = record["PackID"] as? [String],
                          let packIDString = packIDList.first,
                          let packID = UUID(uuidString: packIDString),
                          let packInfo = record["PackInfo"] as? [String],
                        
                          let asset = record["PackImage"] as? CKAsset,
                          let imageData = try? Data(contentsOf: asset.fileURL!),
                          let image = UIImage(data: imageData) else {
                        return nil
                    }

                    return PackData(id: packID, packInfo: packInfo.first ?? "No Info", image: image)
                }

                print("Updated packs array: \(self.packs)")
            }
        }
    }
}

struct AddPackView: View {
    @Binding var isPresented: Bool
    var onSave: (String, UIImage?) -> Void
    @State private var showingImagePicker = false

    @State private var packName: String = ""
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack {
            ZStack {
                Text("Add Pack")
                    .font(.title)
                    .foregroundColor(Color.white)
                    .padding()

                HStack {
                    Image(systemName: "chevron.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20) // Adjust the size as needed
                        .foregroundColor(Color.white)
                        .padding()
                    Spacer() // This pushes the chevron to the left
                }

                HStack {
                    Spacer() // This pushes the button to the right
                    Button(action: {
                        self.isPresented = false
                        self.onSave(self.packName, self.selectedImage)
                    }) {
                        Text("Save")
                            .font(.title3)
                            .foregroundColor(Color(red: 0/255, green: 211/255, blue: 255/255))
                            .padding()
                            .background(Color.clear)
                            .cornerRadius(10)
                    }

                }
            }
Spacer()
            TextField("Enter Pack Name", text: $packName)
                .padding()
                .background(Color(red: 41/255, green: 41/255, blue: 41/255))
                .cornerRadius(10)
                .padding(.horizontal)
                .multilineTextAlignment(.center) // Align the text to the center


            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(selectedImage != nil ? Color.clear : Color(red: 41/255, green: 41/255, blue: 41/255))

                    .frame(width: 360, height: 600) // Set the frame to the specified dimensions
                    .overlay(
                        Group {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill) // Fill the frame while maintaining aspect ratio
                                    .clipped() // Clip the overflowing parts of the image
                            } else {
                                Text("Tap to Add Photo")
                                    .foregroundColor(Color.white)
                                    .padding()
                                    .multilineTextAlignment(.center) // Align the text to the center
                            }
                        }
                    )
                    .cornerRadius(25) // Apply corner radius to the RoundedRectangle
                    .onTapGesture {
                        showingImagePicker = true
                    }
            }
            .padding()

            Spacer()

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 18/255, green: 18/255, blue: 18/255).edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: self.$selectedImage)
        }
    }
}



struct WorkoutPacks_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutPacks().environmentObject(AuthViewModel())
    }
}

struct PackData: Identifiable, Equatable {
    var id: UUID
    var packInfo: String
    var image: UIImage?
}
