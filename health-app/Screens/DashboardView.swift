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
    
    @State private var isShowingPermissionViewSheet = false
    @State private var selectedStat: HealthMetricType = .steps
    @State private var isShowingAlert = false
    @State private var fetchError: STError = .noData
    
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
                        WeightDiffBarChart(chartData: ChartMath.averageDailyWeightDiffs(for: hkManager.weightDiffData))
                        
                    case .calories:
                        
                        CaloriesTodayCard(chartData: hkManager.caloriesData)
                        CaloriesLineChart(selectedStat: selectedStat, chartData: hkManager.caloriesData)
                        CaloriesBarChart(selectedStat: selectedStat, chartData: hkManager.caloriesData)
                    }
                }
            }
            .padding()
            .task {
                
                do {
                    try await hkManager.fetchStepCount()
                    try await hkManager.fetchWeights()
                    try await hkManager.fetchWeightDifferential()
                    try await hkManager.fetchCalories()
                    
                } catch STError.authNotDetermined{
                    isShowingPermissionViewSheet = true
                } catch STError.noData {
                    fetchError = .noData
                    isShowingAlert = true
                } catch {
                    fetchError = .unabletoCompleteRequest
                    isShowingAlert = true
                }
                
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricType.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionViewSheet, onDismiss: {
                // fetch health data
            }, content: {
                HealthKitPermissionView()
            })
            .alert(isPresented: $isShowingAlert, error: fetchError) { fetchError in
                // Actions
            } message: { fetchError in
                Text(fetchError.failureReason)
            }
        }
        .tint(selectedStat.tintColor)
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
