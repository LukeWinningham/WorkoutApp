//
//  TopProfile.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/6/24.
//

import SwiftUI
import Combine

struct TopProfile: View {
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.clear) // Use any color that fits your design
                .frame(height: 70) // Adjust height as needed
            
                .overlay(
                    HStack(spacing: 20) {
                        // Use ZStack to overlay the image on the circle
                        ZStack {
                            Circle()
                                .foregroundColor(Color(red: 0.07, green: 0.69, blue: 0.951))
                                .frame(width: 95.0, height: 95.0) // Adjust the size of the circle as needed
                                .opacity(0.5)
                            
                            // Replace "person.fill" with your actual image name
                            Image("me")
                                .resizable() // Make the image resizable
                            
                                .aspectRatio(contentMode: .fill) // Fill the frame while preserving aspect ratio
                                .frame(width: 105.0, height: 105.0) // Match the circle's size
                                .clipShape(Circle()) // Clip the image to a circular shape
                                .shadow(radius: 5)
                        }
                        .padding(.leading, 5)
                        
                        VStack(alignment: .leading){
                            Spacer()
                            Text("Luke")
                                .font(.title2)
                                .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                                .bold()
                            
                                .bold()
                                .padding(.trailing)
                            Text("Currently Cutting")
                                .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                .font(.subheadline)
                            Spacer()
                            HStack{
                                Image(systemName: "flame.fill")
                                    .foregroundColor(Color.orange) // Use your own image or system image name
                                Text("32")
                                    .foregroundColor(Color.orange)
                            }
                        }
                        
                        Spacer()
                        

                    }
                    
                    // Add some horizontal padding inside the overlay
                )
            
        }
        .padding(.horizontal, 10.0)
    }
}

// Correct way to define a preview provider for your SwiftUI view
struct TopProfile_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TopProfile()
                .environmentObject(WorkoutData())
        }
    }
}
