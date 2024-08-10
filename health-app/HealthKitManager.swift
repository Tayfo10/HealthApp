//
//  HealthKitManager.swift
//  health-app
//
//  Created by Tayfun Sener on 9.08.2024.
//

import Foundation
import HealthKit
import Observation

@Observable class HealthKitManager {
    
    
    let store = HKHealthStore()
    
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.activeEnergyBurned), HKQuantityType(.bodyMass)]
    
}
