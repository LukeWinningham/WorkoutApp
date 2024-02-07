//
//  FriendActivity.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/5/24.
//
import SwiftUI
import Combine

struct FriendActivity: View {
    var body: some View {
        VStack {
            HStack(spacing: 170) {
                Text("Latest Activity")
                    .font(.headline)
                    .bold()

                Text("See more")
            }

            ScrollView {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.908)) // Use any color that fits your design
                    .frame(height: 70) // Adjust height as needed
                                 
                    .overlay(
                        HStack(spacing: 30) {
                            // Use ZStack to overlay the image on the circle
                            ZStack {
                                Circle()
                                    .foregroundColor(Color(red: 0.07, green: 0.69, blue: 0.951))
                                    .frame(width: 45.0, height: 45.0) // Adjust the size of the circle as needed
                                    .opacity(0.5)
                                
                                // Replace "person.fill" with your actual image name
                                Image("me")
                                    .resizable() // Make the image resizable
                                
                                    .aspectRatio(contentMode: .fill) // Fill the frame while preserving aspect ratio
                                    .frame(width: 55.0, height: 55.0) // Match the circle's size
                                    .clipShape(Circle()) // Clip the image to a circular shape
                                    .shadow(radius: 5)
                            }
                       
                            VStack{
                                Spacer()
                                Text("Luke Completed A Workout!")
                                    .font(.callout)
                                    .foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255))
                                    .bold()
                                    
                                    .bold()
                                    .padding(.trailing)
                                Text("About 2 mins ago")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                Spacer()
                                
                            }
                            
                        }
                        
                             // Add some horizontal padding inside the overlay
                    )
             
            }
            .padding(.horizontal, 20.0)
        }
    }
}

// Correct way to define a preview provider for your SwiftUI view
struct FriendActivity_Previews: PreviewProvider {
    static var previews: some View {
        FriendActivity()
    }
}
