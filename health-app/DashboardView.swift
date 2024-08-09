//
//  ContentView.swift
//  health-app
//
//  Created by Tayfun Sener on 8.08.2024.
//

import SwiftUI

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
            return .orange
        case .calories:
            return .green
        }
    }
}

struct DashboardView: View {
    
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
                        NavigationLink(value: selectedStat) {
                            HStack{
                                VStack (alignment: .leading){
                                    Label("Steps", image: "figure.walk.motion")
                                        .font(.title3.bold())
                                        .foregroundColor(.mint)
                                    Text("Avg:10K Steps")
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.mint)
                            }
                        }
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 12)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 150)
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
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricType.self) { metric in
                HealthDataListView(metric: metric)
                
            }
        }
        .tint(selectedStat.tintColor)
    }
}

#Preview {
    DashboardView()
}
