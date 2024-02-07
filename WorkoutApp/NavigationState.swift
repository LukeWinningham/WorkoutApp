//
//  NavigationState.swift
//  WorkoutApp
//
//  Created by Luke Winningham on 2/5/24.
//

import SwiftUI
import Combine

class NavigationState: ObservableObject {
    @Published var selectedTab: Int = 0
}


