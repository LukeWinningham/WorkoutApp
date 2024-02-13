//
//  AllExercises.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/10/24.
//
import SwiftUI
import Combine

struct AllExercises: View {
    @ObservedObject var viewModel: ExercisesViewModel
    @State private var searchText = ""
    @State private var selectedFilter: String? = nil
    
    // Define a structure to hold both exercise name and its category
    struct ExerciseDisplay {
        let name: String
        let category: String
    }
    
    // Create a flat list of exercises that match the search criteria
    private var filteredExercises: [ExerciseDisplay] {
        viewModel.exercises.flatMap { exerciseCategory in
            exerciseCategory.exercises.filter { exercise in
                exercise.lowercased().contains(searchText.lowercased()) || searchText.isEmpty
            }.map { exercise in
                ExerciseDisplay(name: exercise, category: exerciseCategory.name)
            }
        }.filter { exerciseDisplay in
            selectedFilter == nil || exerciseDisplay.category == selectedFilter
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 18/255, green: 18/255, blue: 18/255)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("Choose An Exercise")
                    .font(.title)
                    .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                    .padding()
                HStack{
                    TextField("Search exercises...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Picker("Filter", selection: $selectedFilter) {
                        Text("All").tag(String?.none)
                        ForEach(viewModel.exercises.map { $0.name }, id: \.self) { category in
                            Text(category).tag(category as String?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.all)
                }
                ScrollView {
                    ForEach(filteredExercises, id: \.name) { exerciseDisplay in
                        VStack(alignment: .leading) {
                            Text(exerciseDisplay.name)
                                .font(.headline)
                                .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                            
                            Text(exerciseDisplay.category)
                                .font(.subheadline)
                                .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                            Divider()
                        }
                        .padding()
                    }
                }
            }
            .onAppear(perform: viewModel.loadExercises)
        }
    }
}

struct AllExercises_Previews: PreviewProvider {
    static var previews: some View {
        AllExercises(viewModel: ExercisesViewModel())
    }
}

