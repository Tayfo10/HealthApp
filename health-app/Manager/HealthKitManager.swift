//
//  HealthKitManager.swift
//  health-app
//
//  Created by Tayfun Sener on 9.08.2024.
//

import Foundation
import HealthKit
import Observation

enum STError: LocalizedError {
    case authNotDetermined
    case noData
    case unabletoCompleteRequest
    case sharingDenied(quantityType: String)
    case invalidValue
    
    var errorDescription: String? {
        switch self {
        case .authNotDetermined:
            "Need Access to Health Data"
        case .noData:
            "No Write Access"
        case .unabletoCompleteRequest:
            "No Data"
        case .sharingDenied(_):
            "Unable to Complete Request"
        case .invalidValue:
            "Invalid Value"
        }
    }
    
    var failureReason: String {
        switch self {
        case .authNotDetermined:
            "You have not given to your health data. Please go to Settings > Health > Data Access & Devices."
        case .noData:
            "We are unable to complete your request at this time.\n\nPlease try again later or contact support."
        case .unabletoCompleteRequest:
            "There is no data for this Health Statistic."
        case .sharingDenied(let quantityType):
            "You have denied access to upload your \(quantityType) data. \n\nYou can change this in Settings > Health > Data Access & Devices."
        case .invalidValue:
            "Must be a numeric value with a maximum of one decimal place."
        }
    }
}

@Observable class HealthKitManager {
    
    let store = HKHealthStore()
    
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.activeEnergyBurned), HKQuantityType(.bodyMass)]
    
    var stepData:[HealthMetric] = []
    var weightData:[HealthMetric] = []
    var weightDiffData: [HealthMetric] = []
    var caloriesData:[HealthMetric] = []
    
    func fetchStepCount() async throws {
        throw STError.noData
        
        guard store.authorizationStatus(for: HKQuantityType(.stepCount)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        
        
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
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unabletoCompleteRequest
        }
    }
    
    func fetchWeights() async throws{
        
        guard store.authorizationStatus(for: HKQuantityType(.bodyMass)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
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
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unabletoCompleteRequest
        }
    }
    
    func fetchWeightDifferential() async throws {
        
        guard store.authorizationStatus(for: HKQuantityType(.bodyMass)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -29, to: endDate)!
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
            weightDiffData = weights.statistics().map {
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
            }
            
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unabletoCompleteRequest
        }
    }
    
    func fetchCalories() async throws {
        
        guard store.authorizationStatus(for: HKQuantityType(.activeEnergyBurned)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
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
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unabletoCompleteRequest
        }
    }

    func addStepData(for date: Date, value: Double) async throws {
        throw STError.sharingDenied(quantityType: "step count")
        
        let status = store.authorizationStatus(for: HKQuantityType(.stepCount))
        switch status {
        case .notDetermined:
            STError.authNotDetermined
        case .sharingDenied:
            STError.sharingDenied(quantityType: "step count")
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
    
    func addWeightData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.bodyMass))
        switch status {
        case .notDetermined:
            STError.authNotDetermined
        case .sharingDenied:
            STError.sharingDenied(quantityType: "weight")
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
    
    func addCaloryData(for date: Date, value: Double) async throws{
        let status = store.authorizationStatus(for: HKQuantityType(.activeEnergyBurned))
        switch status {
        case .notDetermined:
            STError.authNotDetermined
        case .sharingDenied:
            STError.sharingDenied(quantityType: "calories")
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
    
    // This function may be used later in the project. Used to inject mockData.
        func addSimulatorData() async {
    
            var mockSamples: [HKQuantitySample] = []
    
            for i in 0..<28 {
    
                let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
                let endDate = Calendar.current.date(byAdding: .second, value: 1, to: startDate)!
    
                let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4_000...20_000))
                let weightQuantity = HKQuantity(unit: .pound(), doubleValue: .random(in: 160 + Double(i/3)...165 + Double(i/3)))
                let caloriesQuantity = HKQuantity(unit: .largeCalorie(), doubleValue: .random(in: 100...900))
    
                let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: startDate, end: endDate)
                let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuantity, start: startDate, end: endDate)
                let caloriesSample = HKQuantitySample(type: HKQuantityType(.activeEnergyBurned), quantity: caloriesQuantity, start: startDate, end: endDate)
    
                mockSamples.append(stepSample)
                mockSamples.append(weightSample)
                mockSamples.append(caloriesSample)
    
            }
    
            try! await store.save(mockSamples)
    
        }
    
}
