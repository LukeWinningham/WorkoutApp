//
//  QuickInfo.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/6/24.
//

import SwiftUI
import Combine

struct QuickInfo: View {

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 41/255, green: 41/255, blue: 41/255)) // Use any color that fits your design
                .frame( height: 70) // Adjust height as needed
                .shadow(radius: 5) // Adjust shadow radius as needed
                .overlay(
                    
                    
                    VStack {
                        Text("5'9")
                            .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                            .font(.title2)
                            .bold()
                        Text("Height")
                            .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                            .font(.headline)
                    }
                    
                    
                )
                .padding(.horizontal, 10) // Padding applied to the Button

            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 41/255, green: 41/255, blue: 41/255)) // Use any color that fits your design
                .frame( height: 70) // Adjust height as needed
                .shadow(radius: 5) // Adjust shadow radius as needed
                .overlay(
                    
                    
                    VStack {
                        Text("180 lbs")
                            .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                            .font(.title2)
                            .bold()
                        Text("Weight")
                            .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                            .font(.headline)
                    }
                    
                    
                )
                .padding(.horizontal, 10) // Padding applied to the Button

            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 41/255, green: 41/255, blue: 41/255)) // Use any color that fits your design
                .frame(height: 70) // Adjust height as needed
                .shadow(radius: 5) // Adjust shadow radius as needed
                .overlay(
                    
                    
                    VStack {
                        Text("20")
                            .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                            .font(.title2)
                            .bold()
                        Text("Age")
                            .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                            .font(.headline)
                    }
                    
                    
                )
                .padding(.horizontal, 10) // Padding applied to the Button

        }
        }

    }


// Correct way to define a preview provider for your SwiftUI view
struct QuickInfo_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            QuickInfo()
                .environmentObject(WorkoutData())
        }
    }
}
