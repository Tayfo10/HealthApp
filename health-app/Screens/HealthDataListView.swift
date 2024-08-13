//
//  HealthDataListView.swift
//  health-app
//
//  Created by Tayfun Sener on 9.08.2024.
//

import SwiftUI

struct HealthDataListView: View {
    
    @Environment(HealthKitManager.self) private var hkManager
    
    @State private var isShowingAddData = false
    
    @State private var addDataDate: Date = .now
    @State private var valueToAdd: String = ""
    
    var metric: HealthMetricType
    
    var listData: [HealthMetric] {
        switch metric {
        case .steps:
            hkManager.stepData
        case .weight:
            hkManager.weightData
        case .calories:
            hkManager.caloriesData
        }
    }
    
    var fractionDecider: Int {
        switch metric {
        case .steps:
            0
        case .weight:
            2
        case .calories:
            1
        }
    }
    
    var body: some View {
        List(listData.reversed()) {data in
            HStack {
                Text(data.date, format: .dateTime.year().month().day())
                Spacer()
                Image("arrow.forward.square.fill" + ".\(metric)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 18)
                
                Text(data.value, format: .number.precision(.fractionLength(fractionDecider)))
                    .frame(width:60)
            }
        }
        .navigationTitle(metric.title)
        .sheet(isPresented: $isShowingAddData) {
            addDataView
        }
        .toolbar {
            Button("Add Data", systemImage: "plus") {
                isShowingAddData = true
            }
        }
    }
    
    var addDataView: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $addDataDate, displayedComponents: .date)
                HStack {
                    Text(metric.title)
                    Spacer()
                    TextField("Value", text: $valueToAdd)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 150)
                        .keyboardType(metric == .steps || metric == .calories ? .numberPad : .decimalPad)
                }
            }
            .navigationTitle(metric.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        Task{
                            switch metric {
                            case .steps:
                                await hkManager.addStepData(for: addDataDate, value: Double(valueToAdd)!)
                                await hkManager.fetchStepCount()
                                isShowingAddData = false
                            case .weight:
                                await hkManager.addWeightData(for: addDataDate, value: Double(valueToAdd)!)
                                await hkManager.fetchWeights()
                                await hkManager.fetchWeightDifferential()
                                isShowingAddData = false
                            case .calories:
                                await hkManager.addCaloryData(for: addDataDate, value: Double(valueToAdd)!)
                                await hkManager.fetchCalories()
                                isShowingAddData = false
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss") {
                        isShowingAddData = false
                    }
                }
            }
        }
    }
}

#Preview {
    HealthDataListView(metric: .steps)
        .environment(HealthKitManager())
}
