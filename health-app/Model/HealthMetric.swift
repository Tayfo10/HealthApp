//
//  HealthMetric.swift
//  health-app
//
//  Created by Tayfun Sener on 11.08.2024.
//

import Foundation

struct HealthMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
