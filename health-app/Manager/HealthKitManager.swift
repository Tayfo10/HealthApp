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
    
    var stepData:[HealthMetric] = []
    var weightData:[HealthMetric] = []
    var caloriesData:[HealthMetric] = []
    
    
    func fetchStepCount() async {
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)!
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate:queryPredicate)
        
        let everyDay = DateComponents(day:1)
        
        let sumOfStepsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum,
            anchorDate: endDate,
            intervalComponents: everyDay)
        
        do {
            
            let stepCounts = try await sumOfStepsQuery.result(for: store)
            stepData = stepCounts.statistics().map {
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
            
        } catch {
            
        }
        
        
        
    }
    
    func fetchWeights() async {
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)!
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate:queryPredicate)
        
        let everyDay = DateComponents(day:1)
        
        let weightQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .mostRecent,
            anchorDate: endDate,
            intervalComponents: everyDay)
        
        do {
            
            let weights = try await weightQuery.result(for: store)
            weightData = weights.statistics().map {
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
            }
            
        } catch {
            
        }
        
        
           
    }
    
    func fetchCalories() async {
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)!
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.activeEnergyBurned), predicate:queryPredicate)
        
        let everyDay = DateComponents(day:1)
        
        let sumOfCaloriesQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum,
            anchorDate: endDate,
            intervalComponents: everyDay)
        
        
        
        do {
            let caloriesCount = try await sumOfCaloriesQuery.result(for: store)
            caloriesData = caloriesCount.statistics().map {
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .pound()) ?? 0)
            }
            
        } catch {
            
        }
        
        
    }

    
// This function may be used later in the project. Used to inject mockData.
//    func addSimulatorData() async {
//        
//        var mockSamples: [HKQuantitySample] = []
//        
//        for i in 0..<28 {
//            
//            let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
//            let endDate = Calendar.current.date(byAdding: .second, value: 1, to: startDate)!
//            
//            let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4_000...20_000))
//            let weightQuantity = HKQuantity(unit: .pound(), doubleValue: .random(in: 160 + Double(i/3)...165 + Double(i/3)))
//            let caloriesQuantity = HKQuantity(unit: .largeCalorie(), doubleValue: .random(in: 100...900))
//            
//            let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: startDate, end: endDate)
//            let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuantity, start: startDate, end: endDate)
//            let caloriesSample = HKQuantitySample(type: HKQuantityType(.activeEnergyBurned), quantity: caloriesQuantity, start: startDate, end: endDate)
//            
//            mockSamples.append(stepSample)
//            mockSamples.append(weightSample)
//            mockSamples.append(caloriesSample)
//            
//        }
//        
//        try! await store.save(mockSamples)
//        
//    }
    
}
