//
//  AllExercises.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/10/24.
//


import SwiftUI
import Combine
import CloudKit

struct AllExercises: View {
    @Environment(\.presentationMode) var presentationMode
    var dayID: CKRecord.ID  // To accept dayID

    @State private var searchText = ""
    @State private var selectedFilter: String? = nil
    @EnvironmentObject var viewModel: ExercisesViewModel
    @State private var hasScrolled = false  // State to track if user has scrolled

    struct ExerciseDisplay {
        let name: String
        let category: String
    }

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
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.backward")
                                .imageScale(.small)
                                .font(.title)
                                .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                                .shadow(radius: 3)
                        }
                    }
                }

            VStack {
                VStack {
                    Text("Choose An Exercise")
                        .font(.title)
                        .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                        
                    HStack {
                        TextField("Search exercises...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)

                        Picker("Filter", selection: $selectedFilter) {
                            Text("All").tag(String?.none)
                            ForEach(viewModel.exercises.map { $0.name }, id: \.self) { category in
                                Text(category).tag(category as String?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal)
                    }
                }
                .background(hasScrolled ? Color(red: 18/255, green: 18/255, blue: 18/255) : Color(red: 18/255, green: 18/255, blue: 18/255))
             
                .shadow(color: hasScrolled ? Color.black.opacity(0.2) : Color.clear, radius: hasScrolled ? 5 : 0, x: 0, y: hasScrolled ? 5 : 0)
                .animation(.easeInOut, value: hasScrolled)

                ScrollView {
                    GeometryReader { geometry in
                        Color.clear.preference(key: ViewOffsetKey.self, value: geometry.frame(in: .named("scrollView")).minY)
                    }
                    .frame(height: 0)

                    ForEach(filteredExercises, id: \.name) { exerciseDisplay in
                        NavigationLink(destination: AddExercise(exerciseName: exerciseDisplay.name, exerciseCategory: exerciseDisplay.category, dayID: dayID)) {
                            VStack(alignment: .leading) {
                                Text(exerciseDisplay.name)
                                    .font(.headline)
                                    .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                                Text(exerciseDisplay.category)
                                    .font(.subheadline)
                                    .foregroundColor(Color(red: 167/255, green: 167/255, blue: 167/255))
                                Divider()
                            }
                        }
                        .padding()
                    }
                }
                .coordinateSpace(name: "scrollView")
                .onPreferenceChange(ViewOffsetKey.self) { value in
                    hasScrolled = value < 0
                }
                .onAppear {
                    viewModel.loadExercises()
                }
            }
        }
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct AllExercises_Previews: PreviewProvider {
    static var previews: some View {
        let exercisesViewModel = ExercisesViewModel()
        let dummyDayID = CKRecord.ID(recordName: UUID().uuidString)

        AllExercises(dayID: dummyDayID)
            .environmentObject(exercisesViewModel)
    }
}
