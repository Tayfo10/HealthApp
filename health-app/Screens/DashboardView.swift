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
                    
                    VStack {
                        HStack{
                            VStack (alignment: .leading){
                                Label("Steps", image: "figure.walk.motion")
                                    .font(.title3.bold())
                                    .foregroundColor(.mint)
                                Text("\(Int(hkManager.stepData.last?.value ?? 0))")
                                    .font(.title2.bold())
                                    .foregroundStyle(.black)
                            }
                            Spacer()
                            Text("Today")
                        }
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 12)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    
                    StepBarChart(selectedStat: selectedStat, chartData: hkManager.stepData)
                    
                    VStack(alignment: .leading) {
                        VStack (alignment: .leading){
                            Label("Averages", image: "calendar")
                                .font(.title3.bold())
                                .foregroundColor(.mint)
                            Text("Last 28 Days")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 12)
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 250)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                }
            }
            .padding()
            .task {
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
