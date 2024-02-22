//
//  ProfileView.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/6/24.
//

import SwiftUI
import Combine

struct ProfileView: View {
    @EnvironmentObject var workoutData: WorkoutData
    @EnvironmentObject var authViewModel: AuthViewModel // Access the AuthViewModel

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack(alignment: .top) { // Align content to the top
            Color(red: 18/255, green: 18/255, blue: 18/255)
                .edgesIgnoringSafeArea(.all)
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
            VStack(spacing: 0) { // Use VStack to place the border right below the image
                Image("background") // Ensure you have an image named "background" in your assets
                    .resizable()
                    .aspectRatio(contentMode: .fill) // Fill the frame while preserving aspect ratio
                    .frame(width: UIScreen.main.bounds.width, height: 215) // Use the screen width for the image
                    .clipShape(RoundedRectangle(cornerRadius: 0)) // You may not need a corner radius here

                Rectangle() // This creates the border line
                    .fill(Color(red: 41/255, green: 41/255, blue: 41/255)) // Set the border color here
                    .frame(height: 2) // Set the border thickness here
            }
            .edgesIgnoringSafeArea(.top) // Allow the image and border to extend to the top edge of the screen

            VStack(spacing: 30.0) {
                Spacer().frame(height: 70) // Adjust this height to move the content barely below the image

                TopProfile()
                QuickInfo()
                AccountCard()
               // Other()
            }
        }
    }
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel()) // Provide the AuthViewModel for the preview
    }
}

