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
            .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.908)) // Use any color that fits your design
            .frame(height: 170) // Adjust size as needed
            .shadow(radius: 5) // Adjust shadow radius as needed
            .overlay(
                VStack(alignment: .leading, spacing: 20.0) { // Reduced spacing to accommodate elements better
                    Text("Account")
                        .font(.title2)
                        .bold()
                        .padding(.top, 20) // Reduced padding to align with the overall layout
                        .padding(.leading, 10) // Apply 10 points of padding to the leading edge
                    HStack {
                        VStack(alignment: .leading, spacing: 10) { // Added alignment and spacing
                            HStack {
                                Image(systemName: "person.2")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 1.0, green: 0.677, blue: 0.215))
                                Text("Friends")
                                    .font(.title2)
                                    
                                    .foregroundColor(Color.gray)
                            }
                            .padding(.leading, 15) // Added padding to move "Friends" to the right
                            
                            HStack {
                                Image(systemName: "doc.plaintext")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 1.0, green: 0.677, blue: 0.215))
                                VStack(alignment: .center) { // Align text to leading
                                    Text("Personal")
                                        .font(.title2)
                                        .foregroundColor(Color.gray)
                                    Text("Data")
                                        .font(.title2)
                                        .foregroundColor(Color.gray)
                                }
                            }
                            .padding(.leading, 20) // Added padding to move "Personal Data" to the right
                        }
                        Spacer() // This will push the second VStack to the end of the HStack
                        VStack(alignment: .leading, spacing: 10) { // Matched alignment and spacing with the first VStack
                            HStack {
                                Image(systemName: "trophy")
                                    .font(.title3)
                                    .foregroundColor(Color(red: 1.0, green: 0.677, blue: 0.215))
                                Text("Achievements")
                                    .font(.title2)
                                    .foregroundColor(Color.gray)
                            }
                            HStack {
                                Image(systemName: "chart.bar")
                                    .font(.title2)
                                    .foregroundColor(Color(red: 1.0, green: 0.677, blue: 0.215))
                                VStack(alignment: .leading) { // Align text to leading
                                    Text("Workout")
                                        .font(.title2)
                                        .foregroundColor(Color.gray)
                                    Text("Progress")
                                        .font(.title2)
                                        .foregroundColor(Color.gray)
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
