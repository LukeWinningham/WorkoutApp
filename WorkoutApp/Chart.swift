//
//  MonthlyHoursOfSunshine.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/3/24.
//

import SwiftUI
import Charts

struct WeightChart: View {
    @EnvironmentObject var workoutData: WorkoutData
    var data: [MonthlyHoursOfSunshine] = [
        MonthlyHoursOfSunshine(id: UUID(), month: 1, hoursOfSunshine: 74),
        MonthlyHoursOfSunshine(id: UUID(), month: 2, hoursOfSunshine: 99),
        MonthlyHoursOfSunshine(id: UUID(), month: 3, hoursOfSunshine: 112),
        MonthlyHoursOfSunshine(id: UUID(), month: 4, hoursOfSunshine: 145),
        MonthlyHoursOfSunshine(id: UUID(), month: 5, hoursOfSunshine: 178),
        MonthlyHoursOfSunshine(id: UUID(), month: 6, hoursOfSunshine: 205),
        MonthlyHoursOfSunshine(id: UUID(), month: 7, hoursOfSunshine: 220),
        MonthlyHoursOfSunshine(id: UUID(), month: 8, hoursOfSunshine: 198),
        MonthlyHoursOfSunshine(id: UUID(), month: 9, hoursOfSunshine: 166),
        MonthlyHoursOfSunshine(id: UUID(), month: 10, hoursOfSunshine: 124),
        MonthlyHoursOfSunshine(id: UUID(), month: 11, hoursOfSunshine: 89),
        MonthlyHoursOfSunshine(id: UUID(), month: 12, hoursOfSunshine: 67)
    ]


    var body: some View {
        Chart(data) {
            LineMark(
                x: .value("Month", $0.date),
                y: .value("Hours of Sunshine", $0.hoursOfSunshine)
            )
            
        }
        .frame(width: 360, height: 220)
        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.067, green: 0.69, blue: 0.951), Color(hue: 1.0, saturation: 0.251, brightness: 0.675)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(10.0)
        .foregroundColor(.white)
         // Change the font color here
    }
}

struct MonthlyHoursOfSunshine: Identifiable {
    var id: UUID
    var date: Date
    var hoursOfSunshine: Double

    init(id: UUID = UUID(), month: Int, hoursOfSunshine: Double) {
        let calendar = Calendar.autoupdatingCurrent
        self.id = id
        self.date = calendar.date(from: DateComponents(year: 2020, month: month))!
        self.hoursOfSunshine = hoursOfSunshine
    }
}




struct WeightChart_Previes: PreviewProvider {
    static var previews: some View {
        WeightChart()
            .environmentObject(WorkoutData())
    }
}
