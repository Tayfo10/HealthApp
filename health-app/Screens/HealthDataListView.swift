//
//  HealthDataListView.swift
//  health-app
//
//  Created by Tayfun Sener on 9.08.2024.
//

import SwiftUI

struct HealthDataListView: View {
    
    @State private var isShowingAddData = false
    
    @State private var addDataDate: Date = .now
    @State private var valueToAdd: String = ""
    
    var metric: HealthMetricType
    
    var body: some View {
        List(0..<28) {i in
            HStack {
                Text(Date(), format: .dateTime.year().month().day())
                Spacer()
                Image("arrow.forward.square.fill" + ".\(metric)")
                Text(10000, format: .number.precision(.fractionLength(metric == .steps || metric == .calories ? 0 : 2)))
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
                        // Do code later
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
}
