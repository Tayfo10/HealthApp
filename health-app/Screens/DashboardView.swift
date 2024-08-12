//
//  ContentView.swift
//  health-app
//
//  Created by Tayfun Sener on 8.08.2024.
//

import SwiftUI
import Charts

enum HealthMetricType: CaseIterable, Identifiable {
    
    case steps, weight, calories
    var id: Self {self}
    
    var title: String {
        switch self {
        case .steps:
            return "Steps"
        case .weight:
            return "Weight"
        case .calories:
            return "Calories"
        }
    }
    
    var tintColor: Color {
        switch self {
        case .steps:
            return .mint
        case .weight:
            return .purple
        case .calories:
            return .green
        }
    }
}

struct DashboardView: View {
    
    @Environment(HealthKitManager.self) private var hkManager
    @AppStorage("hasSeenPermissionView") private var hasSeenPermissionView = false
    @State private var isShowingPermissionViewSheet = false
    @State private var selectedStat: HealthMetricType = .steps
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack (spacing: 20){
                    Picker("Selected Stat", selection: $selectedStat){
                        ForEach(HealthMetricType.allCases) { metric in
                            Text(metric.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    switch selectedStat {
                    case .steps:
                        StepTodayCard(chartData: hkManager.stepData)
                        
                        StepBarChart(selectedStat: selectedStat, chartData: hkManager.stepData)
                        
                        StepPieChart(chartData: ChartMath.averageWeekdayCount(for: hkManager.stepData))
                    case .weight:
                        WeightLineChart(selectedStat: selectedStat, chartData: hkManager.weightData)
                    case .calories:
                        StepTodayCard(chartData: hkManager.stepData)
                    }
                    
                    
                }
            }
            .padding()
            .task {
                await hkManager.fetchWeights()
                await hkManager.fetchStepCount()
                isShowingPermissionViewSheet = !hasSeenPermissionView
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricType.self) { metric in
                HealthDataListView(metric: metric)
                
            }
            .sheet(isPresented: $isShowingPermissionViewSheet, onDismiss: {
                // fetch health data
            }, content: {
                HealthKitPermissionView(hasSeen: $hasSeenPermissionView)
            })
        }
        .tint(selectedStat.tintColor)
    }
    
    
    
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
