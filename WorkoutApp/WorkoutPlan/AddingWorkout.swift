//
//  SwiftUIView.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 1/30/24.
//

import Foundation
import SwiftUI
import Combine
import CloudKit

// MARK: - CustomTextField
struct CustomTextField: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            // This will update the text binding when the text changes in the text field
            text = textField.text ?? ""
        }
    }

    var placeholder: String
    @Binding var text: String
    var placeholderTextColor: UIColor

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.placeholder = placeholder
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderTextColor]
        )
        textField.textColor = UIColor.black
        textField.delegate = context.coordinator
        textField.frame.size.height = 150 // Adjust the height as needed

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        // Update the text field's text property when the binding changes
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
}

// MARK: - KeyboardResponsiveModifier
struct KeyboardResponsiveModifier: ViewModifier {
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, offset)
            .onAppear(perform: subscribeToKeyboardEvents)
    }

    private func subscribeToKeyboardEvents() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            withAnimation {
                offset = keyboardFrame.height
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation {
                offset = 0
            }
        }
    }
}

// MARK: - View Extension
extension View {
    func keyboardResponsive() -> some View {
        self.modifier(KeyboardResponsiveModifier())
    }
}

// MARK: - UniqueItem
struct UniqueItem: Identifiable, Hashable, Codable {
    let id: UUID
    var value: String
    var numberSets: Int? // Number of sets, optional
    var numberReps: Int? // Number of reps, optional
    var time: Int? // Duration in minutes, optional
    var description: String

    init(value: String, numberSets: Int? = nil, numberReps: Int? = nil, time: Int? = nil, description: String) {
        self.id = UUID()
        self.value = value
        self.numberSets = numberSets
        self.numberReps = numberReps
        self.time = time
        self.description = description
    }
}

// MARK: - Day
class Day: Identifiable, ObservableObject, Codable {
    let id: UUID
    var name: String
    @Published var items: [UniqueItem]
  

    enum CodingKeys: CodingKey {
        case id, name, items
    }

    init(id: UUID = UUID(), name: String, items: [UniqueItem] = []) {
        self.id = id
        self.name = name
        self.items = items
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        items = try container.decode([UniqueItem].self, forKey: .items)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(items, forKey: .items)
    }
}

// MARK: - WeekData
class WeekData: ObservableObject {
    static let shared = WeekData()

    @Published var packsDays: [UUID: [Day]] = [:]
    @Published var activePackID: UUID?
    @Published var packIDs: [UUID] = [] // Store fetched pack IDs here

    func addDay(withName name: String) {
        guard let activePackID = activePackID else { return }
        let newDay = Day(name: name)

        if var days = packsDays[activePackID] {
            days.append(newDay)
            packsDays[activePackID] = days
        } else {
            packsDays[activePackID] = [newDay]
        }

        saveDayToCloudKit(day: newDay, forPackID: activePackID)
    }

    private func saveDayToCloudKit(day: Day, forPackID packID: UUID) {
        let record = CKRecord(recordType: "WorkoutPacks")
        
        // Convert UUID to CKRecordValue
        let packRecordID = CKRecord.ID(recordName: packID.uuidString)
        let packReference = CKRecord.Reference(recordID: packRecordID, action: .none)
        
        // Assuming CurrentPack is a field in PersonalData record type
        let personalDataRecord = CKRecord(recordType: "PersonalData")
        personalDataRecord["CurrentPack"] = packReference
        
        
        // Add other Day properties to the record as needed

        let publicDatabase = CKContainer.default().publicCloudDatabase
        publicDatabase.save(record) { savedRecord, error in
            if let error = error {
                print("An error occurred while saving the day to CloudKit: \(error.localizedDescription)")
            } else {
                print("Day saved successfully to CloudKit")
            }
        }
    }


    func fetchPackIDs() {
            // Example logic to fetch pack IDs
            let database = CKContainer.default().publicCloudDatabase
            let query = CKQuery(recordType: "WorkoutPacks", predicate: NSPredicate(value: true))

            database.perform(query, inZoneWith: nil) { [weak self] (records, error) in
                DispatchQueue.main.async {
                    if let records = records, error == nil {
                        self?.packIDs = records.compactMap { record in
                            if let idString = record["PackID"] as? String, let id = UUID(uuidString: idString) {
                                return id
                            }
                            return nil
                        }
                    } else {
                        print("Error fetching pack IDs: \(String(describing: error))")
                    }
                }
            }
        }
    }

// MARK: - DayRow
struct DayRow: View {
    @ObservedObject var day: Day
    @EnvironmentObject var weekData: WeekData
    @State private var showingDeleteButton = false

    var body: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 41/255, green: 41/255, blue: 41/255))
                    .frame(height: 70)
                    .overlay(
                        HStack {
                            Circle()
                                .frame(width: 50, height: 40)
                                .shadow(radius: 5)
                                .foregroundColor( Color(red: 0.07, green: 0.69, blue: 0.951))
                                .opacity(1)
                            
                            Text(day.name)
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                            
                            Spacer()
                        }
                    )
                    .gesture(swipeGesture)
                    .offset(x: showingDeleteButton ? -80 : 0)
                    .animation(.easeInOut, value: showingDeleteButton)
                if showingDeleteButton {
                    Button(action: {
                        if let activePackID = weekData.activePackID,
                           let index = weekData.packsDays[activePackID]?.firstIndex(where: { $0.id == day.id }) {
                            weekData.packsDays[activePackID]?.remove(at: index)
                            // Save changes or perform other necessary actions
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.red)
                            .cornerRadius(8)
                    }

                    .transition(.move(edge: .trailing))
                    .frame(width: 80)
                }
            }
            Divider()
                .background(Color(red: 160/255, green: 160/255, blue: 160/255))
        }
        .padding(.top, 20.0)
    }

    var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.width < -50 {
                    showingDeleteButton = true
                } else {
                    showingDeleteButton = false
                }
            }
            .onEnded { value in
                if value.translation.width > -30 {
                    showingDeleteButton = false
                }
            }
    }
}

// MARK: - AddView
struct AddView: View {
    @EnvironmentObject var weekData: WeekData
    @State private var isTextFieldContainerVisible = false
    @State private var newItem: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var isKeyboardVisible = false
    @State private var showingWorkoutPacks = false // State to control WorkoutView presentation

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color(red: 18/255, green: 18/255, blue: 18/255).edgesIgnoringSafeArea(.all)
                VStack {
                    headerView
                    daysListView
                }    .onAppear {
                    weekData.fetchPackIDs()
                }
                if isTextFieldContainerVisible {
                    textFieldContainerView.padding(.top, 200)
                }
                
            }
            .sheet(isPresented: $showingWorkoutPacks) {
                      WorkoutPacks().environmentObject(weekData)
                  }
            
        }
    }

    var headerView: some View {
        HStack {
            workoutPackButton
            Spacer()
            Text("Add A Day").font(.title).foregroundColor(Color.white)
            Spacer()
            addButton
        }
    }

    var daysListView: some View {
        ScrollView {
            LazyVStack {
                // Display days for the active workout pack
                ForEach(weekData.packsDays[weekData.activePackID ?? UUID()] ?? [], id: \.id) { day in
                    Text(day.name)
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
    }

    // Function to create a long press gesture for reordering
    func longPressGesture(_ index: Int) -> some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .onEnded { _ in
                withAnimation {
                    // Move the selected day to the first position
                    weekData.packsDays[weekData.activePackID ?? UUID()]?.move(fromOffsets: IndexSet(integer: index), toOffset: 0)
                    // Update UserDefaults or CloudKit here if needed
                }
            }
    }

    // Text field container view
    var textFieldContainerView: some View {
        HStack {
            // Blue circle on the left
            Circle()
                .frame(width: 40, height: 40)
                .foregroundColor(Color(red: 0.07, green: 0.69, blue: 0.951))
                .shadow(radius: 3)
            
            // Text field for entering workout name
            CustomTextField(placeholder: "Day Name", text: $newItem, placeholderTextColor: UIColor.lightGray)
                .padding(.horizontal)
                .frame(height: 50)
                
            
            // Button to save the workout
            Button("Save") {
                // Handle save action
                if !newItem.isEmpty {
                    weekData.addDay(withName: newItem) // Add a new day
                    newItem = "" // Reset the text field
                    
                    // Dismiss the keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    isTextFieldContainerVisible = false
                }
            }
            .padding(.trailing)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10) // Rounded rectangle background for the entire container
                .fill(Color(red: 41/255, green: 41/255, blue: 41/255))
                .shadow(radius: 3) // Add shadow
        )
        .padding()
        .padding(.bottom, 20) // Add some bottom padding
    }

    var workoutPackButton: some View {
        Button(action: {
            showingWorkoutPacks = true // Show WorkoutView
        }) {
            Image(systemName: "figure.run.square.stack")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(Color.red)
                .padding()
        }
    }
    
    var addButton: some View {
        Button(action: {
            // Toggle the visibility of the text field container view
            isTextFieldContainerVisible.toggle()
        }) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(Color(red: 0/255, green: 211/255, blue: 255/255))
                .padding()
        }
    }
}


// MARK: - AddView_Previews
struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
            .environmentObject(WeekData.shared)
    }
}
