//
//  WorkoutDetails.swift
//  WorkoutApp
// Take the name of the exercise and make it the key to a dictionary an eachh weight will be a new value to the key
//  Created by Luke Winningham on 1/31/24.
import SwiftUI
import Combine

struct WorkoutDetails: View {
    @ObservedObject var weekData = WeekData.shared
    @State private var currentIndex = 0
    @Environment(\.presentationMode) var presentationMode
    @State private var done = UserDefaults.standard.integer(forKey: "doneKey") // Load done from UserDefaults
    func getCurrentDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: Date())
    }
    
    struct CustomTextField: UIViewRepresentable {
        var placeholder: String
        var text: Binding<String>
        var placeholderColor: UIColor
        
        func makeUIView(context: Context) -> UITextField {
            let textField = UITextField(frame: .zero)
            
            textField.placeholder = placeholder
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
            )
            textField.textColor = UIColor.black
            return textField
        }
        
        func updateUIView(_ uiView: UITextField, context: Context) {
            uiView.text = text.wrappedValue
        }
        
        class Coordinator: NSObject, UITextFieldDelegate {
            var parent: CustomTextField
            
            init(_ textField: CustomTextField) {
                self.parent = textField
            }
            
            func textFieldDidChangeSelection(_ textField: UITextField) {
                parent.text.wrappedValue = textField.text ?? ""
            }
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 217/255, green: 217/255, blue: 217/255).edgesIgnoringSafeArea(.all)
                   
                VStack(spacing: 40) {
                    HStack {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.backward.circle.fill")
                                .imageScale(.medium)
                                .font(.title)
                                .foregroundColor(Color(hue: 0.014, saturation: 0.483, brightness: 0.901))
                        }
                        .padding()
                        Spacer()
                    }
                    if let todayWorkout = weekData.days.first(where: { $0.name == getCurrentDay() }) {
                        if todayWorkout.items.isEmpty {
                            Text("No workouts today")
                                .foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255))
                        } else {
                            VStack(spacing: 20) {
                                Text(todayWorkout.items[currentIndex].value)
                                    .font(.title)
                                    .multilineTextAlignment(.center)
                                    .bold()
                                    .foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255))
                                    .padding(.top, 20)
                                    .padding(.horizontal, 45.0)
                                if let numberSets = todayWorkout.items[currentIndex].numberSets {
                                    Text("Last 3 Sets: 300, 200, 100")
                                        .font(.body)
                                        .foregroundColor(.gray)

                                    ScrollView {
                                        ForEach(0..<numberSets, id: \.self) { setIndex in
                                            RectangleWithText(text: "Set \(setIndex + 1)")
                                        }
                                        .padding(.top, 8.0)
                                        
                                    }
                                    .border(Color.gray, width: 0.2) // Apply border to VStack

                                } else if let time = todayWorkout.items[currentIndex].time {
                                    Text("for \(time) mins")
                                    Spacer()
                                }

                                    }
                        

                            .onTapGesture {
                                UIApplication.shared.endEditing()
                            }
                            
                            HStack(spacing: 100){
                                Button(action: {
                                    if currentIndex < todayWorkout.items.count - 1 {
                                    currentIndex = max(currentIndex - 1, 0)
                                }
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 0.067, green: 0.69, blue: 0.951), Color(hue: 1.0, saturation: 0.251, brightness: 0.675)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 80, height: 40)
                                            .opacity(0.7)
                                        Text("Previous")
                                            .foregroundColor(.white)
                                            .font(.headline)
                                    }
                                    .padding()
                                }
                                
                                
                                Button(action: {
                                    if currentIndex < todayWorkout.items.count - 1 {
                                        currentIndex += 1
                                    }
                                    else{
                                        done += 1
                                        print(done)
                                        UserDefaults.standard.set(done, forKey: "doneKey") // Save done to UserDefaults
                                        print(done)
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 0.067, green: 0.69, blue: 0.951), Color(hue: 1.0, saturation: 0.251, brightness: 0.675)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 80, height: 40)
                                            .opacity(0.7)
                                        Text("Next")
                                            .foregroundColor(.white)
                                            .font(.headline)
                                    }
                                    .padding()
                                }
                                
                            }
                        }
                        
                    } else {
                        Text("No workout for today")
                            .foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255))
                    }
                }
       
            }
        }
        .navigationBarBackButtonHidden(true)

    }
    
}
    
struct RectangleWithText: View {
    var text: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 320.0, height: 60.0)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color(red: 0.067, green: 0.69, blue: 0.951), Color(hue: 1.0, saturation: 0.251, brightness: 0.675)]), startPoint: .topLeading, endPoint: .bottomTrailing))
    
                .foregroundColor(Color.clear)
                .cornerRadius(16)
                .opacity(0.3)
            Text(text)
                .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.348))
                .font(.headline)
                .multilineTextAlignment(.leading)
                .offset(x: -120, y: 0)
            HStack {
                       CustomTextField(
                           placeholder: "Enter Weight",
                           text: .constant(""), // Bind this to a @State variable if you want to capture user input
                           placeholderTextColor: UIColor.gray
                       )
                       .alignmentGuide(.leading) { d in d[.leading] }
                       .offset(x: 230, y: 0)
                   }
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct WorkoutDetails_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetails()
            .environmentObject(WeekData.shared)
    }
}
