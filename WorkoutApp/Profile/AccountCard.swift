//
//  AccountCard.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/6/24.
//
import SwiftUI
import Combine

struct AccountCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(red: 41/255, green: 41/255, blue: 41/255)) // Use any color that fits your design
            .frame(height: 170) // Adjust size as needed
            .shadow(radius: 5) // Adjust shadow radius as needed
            .overlay(
                VStack(alignment: .leading, spacing: 20.0) { // Reduced spacing to accommodate elements better
                    Text("Account")
                        .font(.title2)
                        .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                        .bold()
                        .padding(.top, 20) // Reduced padding to align with the overall layout
                        .padding(.leading, 10) // Apply 10 points of padding to the leading edge
                    HStack {
                        VStack(alignment: .leading, spacing: 10) { // Added alignment and spacing
                            HStack {
                                Image(systemName: "person.2")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 0/255, green: 117/255, blue: 255/255))
                                Text("Friends")
                                    .font(.title2)
                                    
                                    .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                            }
                            .padding(.leading, 15) // Added padding to move "Friends" to the right
                            
                            HStack {
                                Image(systemName: "doc.plaintext")
                                    .foregroundColor(Color.white)
                                    .font(.title2)
                                    
                                VStack(alignment: .center) { // Align text to leading
                                    Text("Personal")
                                        .font(.title2)
                                        .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                    Text("Data")
                                        .font(.title2)
                                        .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                }
                            }
                            .padding(.leading, 20) // Added padding to move "Personal Data" to the right
                        }
                        Spacer() // This will push the second VStack to the end of the HStack
                        VStack(alignment: .leading, spacing: 10) { // Matched alignment and spacing with the first VStack
                            HStack {
                                Image(systemName: "trophy")
                                    .foregroundColor(Color.yellow)
                                    .font(.title3)
                                    
                                Text("Achievements")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                            }
                            HStack {
                                Image(systemName: "figure.run.square.stack")
                                    .foregroundColor(Color.red)
                                    .font(.title2)
                                    
                                VStack() { // Align text to leading
                                    Text("Workout")
                                        .font(.title2)
                                        .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                        .multilineTextAlignment(.center)
                                    Text("Packs")
                                        .font(.title2)
                                        .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                }
                            }
                        }
                        .padding([.leading, .trailing], 15) // Adjusted padding to match the first VStack
                    }
                }
                .padding(.bottom, 20) // Adjusted padding to match the overall layout
            )
            .padding(.horizontal, 15) // Padding applied to the RoundedRectangle
    }
}

struct AccountCard_Previews: PreviewProvider {
    static var previews: some View {
        AccountCard()
    }
}
