//
//  TopProfile.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/6/24.
//

import SwiftUI
import Combine
import CloudKit


extension UIImage {
    func toCKAsset() -> CKAsset? {
        guard let data = self.jpegData(compressionQuality: 0.8) else { return nil }
        let tempDir = NSTemporaryDirectory()
        let tempURL = URL(fileURLWithPath: tempDir).appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        
        do {
            try data.write(to: tempURL)
            return CKAsset(fileURL: tempURL)
        } catch {
            print("Failed to write image data to temp file: \(error)")
            return nil
        }
    }
}

struct TopProfile: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.clear)
                .frame(height: 70)
                .overlay(
                    HStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .foregroundColor(Color(red: 0.07, green: 0.69, blue: 0.951))
                                .frame(width: 95.0, height: 95.0)
                                .opacity(0.5)
                            
                            if let profilePicture = authViewModel.profilePicture {
                                Image(uiImage: profilePicture)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 105.0, height: 105.0)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            } else {
                                Image("person.crop.circle") // Your placeholder image name
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 105.0, height: 105.0)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                        }
                        .padding(.leading, 5)
                        .onTapGesture {
                            self.showingImagePicker = true
                        }
                        
                        VStack(alignment: .leading) {
                            Spacer()
                            Text(authViewModel.username ?? "User")
                                .font(.title2)
                                .foregroundColor(Color.white)
                                .bold()
                                .padding(.trailing)
                            Text("Currently Cutting")
                                .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                .font(.headline)
                        }
                        
                        Spacer()
                    }
                )
                .onAppear {
                        authViewModel.fetchProfilePicture() // Fetch the profile picture when the view appears
                    }
        }
        .padding(.horizontal, 10.0)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(selectedImage: self.$inputImage)
                
        }
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }
        authViewModel.saveProfilePicture(image: inputImage)
    }
}
struct TopProfile_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TopProfile()
                .environmentObject(AuthViewModel()) // Provide the AuthViewModel for the preview
        }
    }
}
