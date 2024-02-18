//
//  PackViewModel.swift
//  Amson
//
//  Created by Luke Winningham on 2/17/24.
//

import Foundation
import Combine

class PackViewModel: ObservableObject {
    @Published var selectedPackDays: [String] = []
}
