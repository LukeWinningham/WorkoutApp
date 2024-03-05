//
//  LiveWorkoutBundle.swift
//  LiveWorkout
//
//  Created by Luke Winningham on 3/4/24.
//

import WidgetKit
import SwiftUI

@main
struct LiveWorkoutBundle: WidgetBundle {
    var body: some Widget {
        LiveWorkout()
        LiveWorkoutLiveActivity()
    }
}
