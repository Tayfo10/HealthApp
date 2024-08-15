//
//  health_appApp.swift
//  health-app
//
//  Created by Tayfun Sener on 8.08.2024.
//

import SwiftUI

@main
struct health_appApp: App {
    
    let hkManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(hkManager)
        }
    }
}
