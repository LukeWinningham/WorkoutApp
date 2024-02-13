//
//  TodaysWorkout.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/5/24.
//
import SwiftUI
import Combine

struct TodaysWorkout: View {

    var body: some View {
        NavigationLink(destination: ContentView()
                                       .environmentObject(WeekData.shared)
                                       .environmentObject(WorkoutData())) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 41/255, green: 41/255, blue: 41/255))
                .frame(height: 70) // Adjust height as needed
                .shadow(radius: 5) // Adjust shadow radius as needed
                .overlay(
                    HStack(spacing: 15) {
                        Circle()
                            .padding(.leading, 10.0)
                            .foregroundColor(Color(red: 0.07, green: 0.69, blue: 0.951))
                            .frame(width: 50, height: 50) // Adjust the size of the circle as needed
                            .opacity(0.5)
                        Spacer()
                        VStack {
                            Text("Today is Leg Day!")
                                .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                                .font(.system(size: 20))
                                .bold()
                            Text("Get Started")
                                .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                .font(.system(size: 15))
                        }
                        
                        Spacer() // Keeps the text and circle aligned to the left, and the forward icon aligned to the right
                        
                        Image(systemName: "chevron.forward")
                            .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))

                            .frame(width: 50, height: 50)
                            .imageScale(.large)
                    }
                )
        }
        .padding(.horizontal, 15) // Padding applied to the Button
    }
}

// Correct way to define a preview provider for your SwiftUI view
struct TodaysWorkout_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TodaysWorkout()
                .environmentObject(WeekData.shared)
                .environmentObject(WorkoutData())
                .environment(\.colorScheme, .light) // Preview in dark mode
        }
    }
}
