//
//  NameOfDay.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/5/24.
//

import SwiftUI
import Combine

struct NameOfDay: View {
    var body: some View {
        VStack {
            Text("Crush Today!")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color(red: 251/255, green: 251/255, blue: 251/255))
                .padding(.top, 20)
        }
    }

    private func getCurrentDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: Date())
    }
}


struct NameOfDay_Previews: PreviewProvider {
    static var previews: some View {
        NameOfDay()
    }
}
