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
    var weightDiffData: [HealthMetric] = []
    var caloriesData:[HealthMetric] = []
    
    /// Fetch last 28 days of step count from HealthKit
    /// - Returns: Array of ``HealthMetric``
    func fetchStepCount() async throws -> [HealthMetric] {
        
        guard store.authorizationStatus(for: HKQuantityType(.stepCount)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, daysBack: 28)
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate:queryPredicate)
        let everyDay = DateComponents(day:1)
        let sumOfStepsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum,
            anchorDate: interval.end,
            intervalComponents: everyDay)
        
        do {
            let stepCounts = try await sumOfStepsQuery.result(for: store)
            return stepCounts.statistics().map {
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unabletoCompleteRequest
        }
    }
    
    /// Fetch most recent weight sample on each day for a specified number of days back from today.
    /// - Parameter daysBack: Days back from today
    /// - Returns: Array of ``HealthMetric``
    func fetchWeights(daysBack: Int) async throws -> [HealthMetric] {
        
        guard store.authorizationStatus(for: HKQuantityType(.bodyMass)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, daysBack: daysBack)
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate:queryPredicate)
        let everyDay = DateComponents(day:1)
        let weightQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .mostRecent,
            anchorDate: interval.end,
            intervalComponents: everyDay)
        
        do {
            let weights = try await weightQuery.result(for: store)
            return weights.statistics().map {
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unabletoCompleteRequest
        }
    }
    
    /// Fetches the calories data over that time period
    /// - Returns: Array of ``HealthMetric``
    func fetchCalories() async throws -> [HealthMetric]{
        
        guard store.authorizationStatus(for: HKQuantityType(.activeEnergyBurned)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, daysBack: 28)
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.activeEnergyBurned), predicate:queryPredicate)
        let everyDay = DateComponents(day:1)
        let sumOfCaloriesQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum,
            anchorDate: interval.end,
            intervalComponents: everyDay)
        
        do {
            let caloriesCount = try await sumOfCaloriesQuery.result(for: store)
            return caloriesCount.statistics().map {
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unabletoCompleteRequest
        }
    }
    
    /// Write step count data to HealthKit. Requires HealthKit write permission.
    /// - Parameters:
    ///   - date: Date for step count value
    ///   - value: Amount of steps on that day
    func addStepData(for date: Date, value: Double) async throws {
        
        
        let status = store.authorizationStatus(for: HKQuantityType(.stepCount))
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "step count")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        
        let stepQuantity = HKQuantity(unit: .count(), doubleValue: value)
        let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: date, end: date)
        do {
            try await store.save(stepSample)
        } catch {
            throw STError.unabletoCompleteRequest
        }
        
    }
    
    /// Write weight value to HealthKit. Requires HealthKit write permission
    /// - Parameters:
    ///   - date: Date for weight value
    ///   - value: Weight value on that day
    func addWeightData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.bodyMass))
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "weight")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        let weightQuantity = HKQuantity(unit: .pound(), doubleValue: value)
        let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuantity, start: date, end: date)
        do {
            try await store.save(weightSample)
        } catch {
            throw STError.unabletoCompleteRequest
        }
        
    }
    
    /// Write calories value to HealthKit. Requires HealthKit write permission
    /// - Parameters:
    ///   - date: Date for weight value
    ///   - value: Calories value on that day
    func addCaloryData(for date: Date, value: Double) async throws{
        let status = store.authorizationStatus(for: HKQuantityType(.activeEnergyBurned))
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(quantityType: "calories")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        let caloryQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: value)
        let calorySample = HKQuantitySample(type: HKQuantityType(.activeEnergyBurned), quantity: caloryQuantity, start: date, end: date)
        do {
            try await store.save(calorySample)
        } catch {
            throw STError.unabletoCompleteRequest
        }
        
    }
    
    /// Creates a DateInterval between two dates
    /// - Parameters:
    ///   - date: End of date interval
    ///   - daysBack: Start of date interval
    /// - Returns: DateInterval
    private func createDateInterval(from date: Date, daysBack: Int) -> DateInterval {
        
        let calendar = Calendar.current
        let startOfEndDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startOfEndDate)!
        let startDate = calendar.date(byAdding: .day, value: -daysBack, to: endDate)!
        return .init(start: startDate, end: endDate)
    }
}
