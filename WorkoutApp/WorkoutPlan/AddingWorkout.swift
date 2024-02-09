//
//  SwiftUIView.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 1/30/24.
//

import SwiftUI
import Foundation
import Combine





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

struct KeyboardResponsiveModifier: ViewModifier {
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, 30)
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

extension View {
    func keyboardResponsive() -> some View {
        self.modifier(KeyboardResponsiveModifier())
    }
}


extension WeekData {
    func updateDay(_ day: Day) {
        if let index = days.firstIndex(where: { $0.id == day.id }) {
            days[index] = day
            saveToUserDefaults()
        }
    }
}
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

class WeekData: ObservableObject {
    static let shared = WeekData()

    @Published var days: [Day] {
        didSet {
            saveToUserDefaults()
        }
    }

    private init() {
        if let savedDays = WeekData.loadFromUserDefaults() {
            self.days = savedDays
        } else {
            let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            self.days = dayNames.map { Day(name: $0) }
        }
    }

    internal func saveToUserDefaults() {
        if let encodedData = try? JSONEncoder().encode(days) {
            UserDefaults.standard.set(encodedData, forKey: "days")
        }
    }

    static func loadFromUserDefaults() -> [Day]? {
        if let savedData = UserDefaults.standard.data(forKey: "days"),
           let decodedDays = try? JSONDecoder().decode([Day].self, from: savedData) {
            return decodedDays
        }
        return nil
    }
}

struct AddView: View {
    @EnvironmentObject var weekData: WeekData  // Access WeekData from the environment

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 217/255, green: 217/255, blue: 217/255).edgesIgnoringSafeArea(.all)
                VStack {
                    headerView
                    daysListView
                }
            }
            
        }
    }

    var headerView: some View {
        HStack {
            Spacer()
            Text("Choose A Day")
                .font(.title2)
                .foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255))
            Spacer()
        }
        .padding()
    }

    var daysListView: some View {
        LazyVStack {
            ForEach(weekData.days) { day in
                NavigationLink(destination: DayDetailView(day: day).environmentObject(weekData)) {
                    DayRow(day: day)
                }
            }
        }
        .padding(.horizontal)
        
    }
}


struct DayRow: View {
    @ObservedObject var day: Day
   

    var body: some View {
        VStack {
            HStack {
                Circle()
                    .frame(width: 50, height: 40)
                    .shadow(radius: 5)
                    .foregroundColor(day.items.isEmpty ? Color(red: 0.07, green: 0.69, blue: 0.951) : Color(hue: 1.0, saturation: 0.251, brightness: 0.675))
                    .opacity(1)

                Text(day.name)
                   
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255))

                Spacer()
            }
          
        
            Divider()
                .background(Color(red: 160/255, green: 160/255, blue: 160/255))
        }
        .padding()
    }
}




struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView().environmentObject(WeekData.shared)
    }
}

   
