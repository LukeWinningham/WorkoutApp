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
            Text("Today is \(getCurrentDay())!")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color(red: 10/255, green: 10/255, blue: 10/255))
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
