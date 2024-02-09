//
//  WorkoutPlanDetails.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/9/24.
//

import SwiftUI
import Combine

struct DayDetailView: View {
    @ObservedObject var day: Day
    @EnvironmentObject var weekData: WeekData
    @Environment(\.presentationMode) var presentationMode
    @State private var newItem: String = ""
    @State private var descriptionText: String = ""
    @State private var setsText: String = ""
    @State private var repsText: String = ""
    @State private var editingIndex: Int? = nil // Add this line to keep track of the item being edited
    
    @State private var isTextFieldContainerVisible = false
    @State private var isKeyboardVisible = false
    @State private var timeText: String = "" // Add this line to keep track of the time input
    @State private var errorMessage: String = ""


    var body: some View {
        ZStack {
            // Tap gesture added to this Color view
            Color(red: 217/255, green: 217/255, blue: 217/255)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    self.isTextFieldContainerVisible = false
                    self.dismissKeyboard()
                }
            
            VStack {
                headerView
                itemsListView
                Spacer()
            }
            
            if isTextFieldContainerVisible {
                textFieldContainerView
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.backward.circle.fill")
                        .imageScale(.medium)
                        .font(.title)
                        .foregroundColor(Color(hue: 0.014, saturation: 0.483, brightness: 0.901))
                        .opacity(isKeyboardVisible ? 0.0 : 1.0) // Hide the button when the keyboard is visible
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            self.isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            self.isKeyboardVisible = false
        }
    }
    
    var headerView: some View {
        Text(day.name)
            .font(.title)
            .foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255))
            .padding()
    }
    
    
    var textFieldContainerView: some View {
        VStack {
            
            VStack(spacing: 10) {
          
            
                CustomTextField(placeholder: "Name of Exercise", text: $newItem, placeholderTextColor: UIColor.lightGray)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5)
                
                    .padding(.horizontal)
                    .frame(height: 50)
                
                CustomTextField(placeholder: "Number of Sets (1 - 10)", text: $setsText, placeholderTextColor: UIColor.lightGray)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5)
                    .padding(.horizontal)
                    .foregroundColor(Color.black)
                    .frame(height: 50)
                CustomTextField(placeholder: "Number of Reps (1 - 99)", text: $repsText, placeholderTextColor: UIColor.lightGray)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5)
                    .padding(.horizontal)
                    .foregroundColor(Color.black)
                    .frame(height: 50)
                CustomTextField(placeholder: "Time (minutes)", text: $timeText, placeholderTextColor: UIColor.lightGray)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(5)
                    .padding(.horizontal)
                    .foregroundColor(Color.black)
                    .frame(height: 50)
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                
                
                Button("Save") {
                    withAnimation {
                        // Check if at least one of sets and reps or time is provided
                        if !newItem.isEmpty {
                            if let sets = Int(setsText.trimmingCharacters(in: .whitespaces)), let reps = Int(repsText.trimmingCharacters(in: .whitespaces)), sets > 0, sets < 11, reps < 100, reps > 0 {
                                if let time = Int(timeText.trimmingCharacters(in: .whitespaces)), time > 0, time < 999 {
                                    errorMessage = "Please provide either Sets and Reps OR Time, but not both."
                                } else {
                                    if let editingIndex = self.editingIndex {
                                        // Editing an existing item
                                        if editingIndex < day.items.count {
                                            var editedItem = day.items[editingIndex]
                                            editedItem.value = newItem
                                            editedItem.numberSets = sets
                                            editedItem.numberReps = reps
                                            editedItem.time = nil // Reset time
                                            editedItem.description = descriptionText
                                            
                                            // Update the item at editingIndex
                                            day.items[editingIndex] = editedItem
                                            weekData.updateDay(day)
                                        }
                                    } else {
                                        // Adding a new workout with Sets and Reps
                                        let newItemToAdd = UniqueItem(value: newItem, numberSets: sets, numberReps: reps, time: nil, description: descriptionText)
                                        day.items.append(newItemToAdd)
                                        weekData.updateDay(day)
                                    
                                    }

                                    // Reset fields and hide container
                                    newItem = ""
                                    setsText = ""
                                    repsText = ""
                                    timeText = ""
                                    descriptionText = ""
                                    errorMessage = ""
                                    isTextFieldContainerVisible = false
                                    self.editingIndex = nil
                                }
                            } else if let time = Int(timeText.trimmingCharacters(in: .whitespaces)), time > 0, time < 999 {
                                if let editingIndex = self.editingIndex {
                                    // Editing an existing item
                                    if editingIndex < day.items.count {
                                        var editedItem = day.items[editingIndex]
                                        editedItem.value = newItem
                                        editedItem.numberSets = nil // Reset sets
                                        editedItem.numberReps = nil // Reset reps
                                        editedItem.time = time
                                        editedItem.description = descriptionText
                                        
                                        // Update the item at editingIndex
                                        day.items[editingIndex] = editedItem
                                        weekData.updateDay(day)
                                    }
                                } else {
                                    // Adding a new workout with Time
                                    let newItemToAdd = UniqueItem(value: newItem, numberSets: nil, numberReps: nil, time: time, description: descriptionText)
                                    day.items.append(newItemToAdd)
                                    weekData.updateDay(day)
                                }
                                
                                // Reset fields and hide container
                                newItem = ""
                                setsText = ""
                                repsText = ""
                                timeText = ""
                                descriptionText = ""
                                errorMessage = ""
                                isTextFieldContainerVisible = false
                                self.editingIndex = nil
                            } else {
                                errorMessage = "Please provide either Sets and Reps OR Time."
                            }
                        }
                    }
                }

                
                .padding()
            }
            .background(Color(UIColor.white))  // Use system background color
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding()
        }
        .edgesIgnoringSafeArea(.all)  // Ensure it covers the entire screen
        .transition(.move(edge: .bottom))
        .animation(.default, value: isTextFieldContainerVisible)  // Apply animation based on isTextFieldContainerVisible
        .keyboardResponsive() // Aply the custom keyboard responsive modifier
    }

        
        private func dismissKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    private func editExercise(at index: Int) {
        editingIndex = index // Set the index of the item being edited
        let item = day.items[index]
        newItem = item.value
        setsText = "\(item.numberSets ?? 0)" // Use nil coalescing operator to provide a default value
        repsText = "\(item.numberReps ?? 0)" // Use nil coalescing operator to provide a default value
        timeText = "\(item.time ?? 0)" // Use nil coalescing operator to provide a default value
        descriptionText = item.description
        isTextFieldContainerVisible = true // Show the text field container for editing
    }

        var itemsListView: some View {
            
            ScrollView {
                LazyVStack {
                    ForEach(day.items.indices, id: \.self) { index in
                        let item = day.items[index]
                        VStack {
                            RoundedRectangle(cornerRadius: 10) // Adjust cornerRadius as needed
                                .fill(Color(hue: 1.0, saturation: 0.0, brightness: 0.908)) // Use any color that fits your design
                                .frame(height: 70) // Adjust height as needed
                                .shadow(radius: 5) // Adjust shadow radius as needed
                                .overlay(
                            HStack {
                                Circle()
                                    .frame(width: 50, height: 40)
                                    .shadow(radius: 5)
                                    .foregroundColor(Color(red: 0.07, green: 0.69, blue: 0.951))
                                    .opacity(1)
                                VStack(alignment: .leading){
                                    Text(item.value)
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255))

                                    if let sets = item.numberSets, let reps = item.numberReps {
                                        Text("\(sets) Sets of \(reps) Reps")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255))
                                    } else if let time = item.time {
                                        Text("Time: \(time) minutes")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255))
                                    }

                                    
                                }
                                Spacer()
                                Spacer(minLength: 50)
                                
                            }
                            
                            )
                        }
                        .padding(10.0)
                        .onTapGesture(count: 2) { // Double-tap gesture
                            // Handle item deletion here
                            day.items.remove(at: index)
                            weekData.updateDay(day)
                        }
                        .onTapGesture(count: 1) { // Double-tap gesture
                            // Handle item deletion here
                            editExercise(at: index)
                        }
                        
                            
                    }
                    
                }
                Button(action: {
                    
                    self.isTextFieldContainerVisible.toggle()  // Show the text field container
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color(red: 1.0, green: 0.677, blue: 0.215))
                }
                .padding()
            }
            .border(Color.gray, width: 0.2) // Apply border to VStack

        }
    }





struct DayDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample Day object
        let sampleDay = Day(name: "Monday", items: [UniqueItem(value: "Push-Ups", numberSets: 3, numberReps: 10, time: nil, description: "Standard push-ups")])
        
        DayDetailView(day: sampleDay) // Pass the sample Day object here
            .environmentObject(WeekData.shared)
    }
}
