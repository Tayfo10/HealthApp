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
    @State private var rawSelectedDate: Date?
    
    var avgStepCount: Double {
        guard !hkManager.stepData.isEmpty else { return 0 }
        let totalSteps = hkManager.stepData.reduce(0) {$0 + $1.value }
        return totalSteps/Double(hkManager.stepData.count)
        
    }
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        let selectedMetric = hkManager.stepData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
        return selectedMetric
    }
    
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
                    
                    VStack {
                        NavigationLink(value: selectedStat) {
                            HStack{
                                VStack (alignment: .leading){
                                    Label("Steps", image: "figure.walk.motion")
                                        .font(.title3.bold())
                                        .foregroundColor(.mint)
                                    Text("Average: \(Int(avgStepCount)) steps")
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.mint)
                            }
                        }
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 12)
                        
                        Chart {
                            if let selectedHealthMetric {
                                RuleMark(x: .value("Selected Metric", selectedHealthMetric.date, unit: .day))
                                    .foregroundStyle(Color.secondary.opacity(0.3))
                                    .offset(y: -10)
                                    .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                        annotationView
                                    }
                                
                            }
                            
                            RuleMark(y: .value("Average", avgStepCount))
                                .foregroundStyle(Color.secondary)
                                .lineStyle(.init(lineWidth: 1, dash:[4]))
                            
                            ForEach(hkManager.stepData) { steps in
                                BarMark(
                                    x: .value("Date", steps.date, unit: .day),
                                        y: .value("Steps", steps.value)
                                )
                                .foregroundStyle(steps.value > avgStepCount ? Color.mint.gradient : Color.gray.gradient)
                                .opacity(rawSelectedDate == nil || steps.date == selectedHealthMetric?.date ? 1.0 : 0.3)
                                
                            }
                        }
                        .chartYAxis {
                            AxisMarks { value in
                                AxisGridLine()
                                    .foregroundStyle(Color.secondary.opacity(0.3))
                                AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
                            }
                        }
                        .chartXAxis {
                            AxisMarks {
                                AxisValueLabel(format: .dateTime.month().day())
                            }
                        }
                        .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                        
                        .frame(height: 130)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    
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
    
    var annotationView: some View {
        VStack(alignment:. leading) {
            Text(selectedHealthMetric?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(0)))
                .fontWeight(.heavy)
                .foregroundStyle(.mint)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .mint.opacity(0.2), radius: 2, x:2, y:2)
        )
    }
    
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
