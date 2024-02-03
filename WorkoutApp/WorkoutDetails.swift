//
//  WorkoutDetails.swift
//  WorkoutApp
// Take the name of the exercise and make it the key to a dictionary an eachh weight will be a new value to the key
//  Created by Luke Winningham on 1/31/24.
import SwiftUI
import Combine

struct WorkoutDetails: View {
    @ObservedObject var weekData = WeekData.shared
    @EnvironmentObject var workoutData: WorkoutData // Use shared data model
    @State private var currentIndex: Int = UserDefaults.standard.integer(forKey: "WorkoutDetailsCurrentIndex")
      @State private var currentSetIndex: Int = UserDefaults.standard.integer(forKey: "WorkoutDetailsCurrentSetIndex")
    @State private var inputWeight = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var done = UserDefaults.standard.integer(forKey: "doneKey")
    @State private var errorMessage: String = ""
 
    func getCurrentDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: Date())
    }

    func advanceSet() {
        guard let weight = Int(inputWeight), weight > 0, weight < 9999 else {
            errorMessage = "Please Enter A Valid Weight"
            return
        }

        if let todayWorkout = weekData.days.first(where: { $0.name == getCurrentDay() }),
           let numberSets = todayWorkout.items[currentIndex].numberSets {
            let exerciseName = todayWorkout.items[currentIndex].value
            workoutData.exerciseWeights[exerciseName, default: []].append(weight)

            workoutData.saveWeights()

            if currentSetIndex + 1 < numberSets {
                currentSetIndex += 1
            } else {
                currentSetIndex = 0
                currentIndex = (currentIndex + 1) % todayWorkout.items.count
            }
            inputWeight = "" // Clear inputWeight after advancing set or exercise
            errorMessage = "" // Clear error message
        }
    }


    
    var body: some View {
        NavigationView {
          ZStack {
                Color(red: 217/255, green: 217/255, blue: 217/255).edgesIgnoringSafeArea(.all)
                ZStack{
                    Spacer()
                
                    VStack(spacing: 40) {
                        VStack(spacing: 40) {
                            HStack {
                                Button(action: {
                                    saveState()
                                    self.presentationMode.wrappedValue.dismiss()
                                }) {
                                    Image(systemName: "chevron.backward.circle.fill")
                                        .imageScale(.medium)
                                        .font(.title)
                                        .foregroundColor(Color(hue: 0.014, saturation: 0.483, brightness: 0.901))
                                }
                                .padding([.leading, .bottom], 30.0)
                                Spacer()
                                Spacer()
                            }
                        }
                        
                        if let todayWorkout = weekData.days.first(where: { $0.name == getCurrentDay() }) {
                            if todayWorkout.items.isEmpty {
                                Text("No workouts today")
                                    .foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255))
                            } else {
                                Text(todayWorkout.items[currentIndex].value)
                                    .font(.largeTitle)
                                    .multilineTextAlignment(.center)
                                    .bold()
                                    .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.199))
                                
                                
                                ZStack(alignment: .bottom){
                                    Spacer()
                                    RoundedRectangle(cornerRadius: 50)
                                        .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.199))
                                        .frame(width: 440.0, height: 600)
                                        .shadow(radius: 20)
                                        .overlay(
                                            VStack(spacing: 10) {
                                                // Check if the current exercise has number of sets and reps defined
                                                if let numberSets = todayWorkout.items[currentIndex].numberSets,
                                                   let numberReps = todayWorkout.items[currentIndex].numberReps {
                                                    Text("You Have \(numberSets) Sets Of \(numberReps) Reps")
                                                        .font(.title)
                                                        .foregroundColor(Color(red: 217/255, green: 217/255, blue: 217/255))
                                                        .bold()
                                                        .padding()
                                                    
                                                    let exerciseName = todayWorkout.items[currentIndex].value
                                                    let weights = workoutData.exerciseWeights[exerciseName] ?? [] // Use workoutData.exerciseWeights
                                                    let personalBest = weights.max() ?? 0 // Find the maximum weight, or 0 if not available
                                                    let lastThreeWeights = weights.suffix(3) // Get the last three weights
                                                    
                                                    // Display personal best
                                                    Text("Personal Best: \(personalBest)")
                                                        .font(.headline)
                                                        .foregroundColor(Color(red: 217/255, green: 217/255, blue: 217/255))
                                                        .padding(.top, 2)
                                                    
                                                    // Display last three weights
                                                    Text("Last 3 Weights: " + lastThreeWeights.map { "\($0)" }.joined(separator: ", "))
                                                        .font(.headline)
                                                        .foregroundColor(Color(red: 217/255, green: 217/255, blue: 217/255))
                                                        .padding(.top, 2)
                                                }

                                                
                                                
                                                RectangleWithText(text: "Set \(currentSetIndex + 1) of \(todayWorkout.items[currentIndex].numberSets ?? 0)", inputWeight: $inputWeight)
                                                    .padding(.top, 40)
                                                Spacer()
                                                Spacer()
                                                Text(errorMessage)
                                                    .foregroundColor(.red)
                                                    .font(.system(size: 14))
                                                Button("Save & Next Set") {
                                                    advanceSet()
                                                }
                                                .padding()
                                                .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.067, green: 0.69, blue: 0.951), Color(hue: 1.0, saturation: 0.251, brightness: 0.675)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                              

                                                Spacer()
                                            }
                                                .padding(.top)
                                        )
                                }
                                .padding(.top, 75.0)
                              
                            }
                        } else {
                            Text("No workout for today")
                                .foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255))
                        }
                    }
                    .padding(.bottom, -90)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadState()
            // Ensure indices are within bounds to avoid out-of-range crashes
            if weekData.days.indices.contains(currentIndex) {
                let day = weekData.days[currentIndex]
                
                if day.items.indices.contains(currentSetIndex) {
                    let exerciseName = day.items[currentSetIndex].value
                    
                    // Safely access weights for the current exercise
                    if let weights = workoutData.exerciseWeights[exerciseName], !weights.isEmpty {
                        inputWeight = String(weights.last!)
                        
                                }
                }
            }
        }

    }
    func loadState() {
        // Load the current index and set index when the view appears
        currentIndex = UserDefaults.standard.integer(forKey: "WorkoutDetailsCurrentIndex")
        currentSetIndex = UserDefaults.standard.integer(forKey: "WorkoutDetailsCurrentSetIndex")
        
        // Load the saved weights for the current exercise
        if weekData.days.indices.contains(currentIndex) {
            let day = weekData.days[currentIndex]
            if day.items.indices.contains(currentSetIndex) {
                let exerciseName = day.items[currentSetIndex].value
                if let weights = workoutData.exerciseWeights[exerciseName], !weights.isEmpty {
                    inputWeight = String(weights.last!)
                }
            }
        }
    }

    func saveState() {
        // Save the current index and set index when the view disappears
        UserDefaults.standard.set(currentIndex, forKey: "WorkoutDetailsCurrentIndex")
        UserDefaults.standard.set(currentSetIndex, forKey: "WorkoutDetailsCurrentSetIndex")
    }

}

struct RectangleWithText: View {
    var text: String
    @Binding var inputWeight: String // Bind input weight to a state variable in the parent view
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 320.0, height: 60.0)
                .foregroundColor(Color(red: 217/255, green: 217/255, blue: 217/255))
                .cornerRadius(16)
                .opacity(1)
            
            Text(text)
                .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.199))
                .font(.headline)
                .padding(.leading, 23.481)
                .offset(x: -120, y: 0)
            ZStack {
                          Rectangle() // Background for the TextField
                    .foregroundColor(Color.clear) // Change this to your desired color
                              .cornerRadius(8) // Optional: Adjust for rounded corners
                              .frame(width: 150, height: 36) // Match the TextField size

                          TextField("Enter Weight", text: $inputWeight)
                              .padding(.leading, 10) // Add some padding inside the TextField
                              .frame(width: 150, height: 36) // Control the size of the TextField
                              .textFieldStyle(PlainTextFieldStyle()) // Remove default styling
                      }
                      .offset(x: 90, y: 0) // Adjust position as needed
                  }
        
    }
}

// `UIApplication.endEditing` extension remains unchanged

struct WorkoutDetails_Previews: PreviewProvider {
    static var previews: some View {
        // Create instances of your environment objects
        let weekData = WeekData.shared
        let workoutData = WorkoutData()
        
        // Provide both environment objects to your WorkoutDetails view
        WorkoutDetails()
            .environmentObject(weekData)
            .environmentObject(workoutData)
    }
}

