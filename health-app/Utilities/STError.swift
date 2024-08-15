//
//  STError.swift
//  health-app
//
//  Created by Tayfun Sener on 14.08.2024.
//

import Foundation

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
