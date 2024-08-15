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
    @State private var isShowingAlert = false
    @State private var writeError: STError = .noData
    @State private var addDataDate: Date = .now
    @State private var valueToAdd: String = ""
    
    var metric: HealthMetricType
    
    var listData: [HealthMetric] {
        switch metric {
        case .steps:
            return hkManager.stepData
        case .weight:
            return hkManager.weightData
        case .calories:
            return hkManager.caloriesData
        }
    }
    
    var fractionDecider: Int {
        switch metric {
        case .steps:
            return 0
        case .weight:
            return 2
        case .calories:
            return 1
        }
    }
    
    var body: some View {
        List(listData.reversed()) { data in
            HStack {
                Text(data.date, format: .dateTime.year().month().day())
                Spacer()
                Image("arrow.forward.square.fill" + ".\(metric)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 18)
                
                Text(data.value, format: .number.precision(.fractionLength(fractionDecider)))
                    .frame(width: 60)
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
            .alert(isPresented: $isShowingAlert, error: writeError) { writeError in
                switch writeError {
                case .authNotDetermined, .noData, .unabletoCompleteRequest, .invalidValue:
                    EmptyView()
                case .sharingDenied(_):
                    Button("Settings") {}
                    
                    Button("Cancel", role: .cancel) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }
            } message: { writeError in
                Text(writeError.failureReason)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        addDataToHealthKit()
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
    
    private func addDataToHealthKit() {
        guard let value = Double(valueToAdd) else {
            writeError = .invalidValue
            isShowingAlert = true
            valueToAdd = ""
            return
        }
        Task {
            do {
                switch metric {
                case .steps:
                    try await hkManager.addStepData(for: addDataDate, value: value)
                    hkManager.stepData = try await hkManager.fetchStepCount()
                    
                case .weight:
                    try await hkManager.addWeightData(for: addDataDate, value: value)
                    async let weightForLineChart = hkManager.fetchWeights(daysBack: 28)
                    async let weightsForDiffBarChart = hkManager.fetchWeights(daysBack: 29)
                    
                    hkManager.weightData = try await weightForLineChart
                    hkManager.weightDiffData = try await weightsForDiffBarChart
                    
                case .calories:
                    try await hkManager.addCaloryData(for: addDataDate, value: Double(valueToAdd)!)
                    hkManager.caloriesData = try await hkManager.fetchCalories()
                }
                isShowingAddData = false
                
            } catch STError.sharingDenied(let quantityType) {
                writeError = .sharingDenied(quantityType: quantityType)
                isShowingAlert = true
                
            } catch {
                writeError = .unabletoCompleteRequest
                isShowingAlert = true
            }
        }
    }
}

#Preview {
    HealthDataListView(metric: .steps)
        .environment(HealthKitManager())
}
