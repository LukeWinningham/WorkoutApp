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
                    .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                    .bold()

          /*      Text("See more")
                    .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255)) */
            }

            ScrollView {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 41/255, green: 41/255, blue: 41/255))
                    .frame(height: 70)
                    .overlay(
                        HStack {
                          
                            // Reduce spacing and add padding to move the image to the left
                            ZStack(alignment: .center) { // Align the image to the center of the ZStack
                                Circle()
                                    .foregroundColor(Color(red: 0.07, green: 0.69, blue: 0.951))
                                    .frame(width: 45.0, height: 45.0)
                                    .opacity(0.5)

                                Image("me")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 55.0, height: 55.0)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                            .padding(.leading, -5) // Adjust this value to move the image further left

                            Spacer() // Use Spacer to push content to the edges

                            VStack(alignment: .center) { // Align the text to the center of VStack
                                Text("Luke Completed A Workout!")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                                    .bold()
                                    .padding(.trailing)
                                Text("About 2 mins ago")
                                    .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                    .font(.system(size: 13))
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing) // Align VStack content to the leading edge
                            .padding(.trailing, 20)
                          
                        }
                       
                        .padding(.horizontal) // Add padding inside the overlay for breathing space
                    )
            }
            .padding(.horizontal, 15.0)
        }
    }
}

struct FriendActivity_Previews: PreviewProvider {
    static var previews: some View {
        FriendActivity()
    }
}
