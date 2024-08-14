//
//  WeightLineChart.swift
//  health-app
//
//  Created by Tayfun Sener on 12.08.2024.
//

import SwiftUI
import Charts


struct WeightLineChart: View {
    
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        return chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    var avgWeight: Double {
        guard !chartData.isEmpty else { return 0 }
        let totalWeight = chartData.reduce(0) {$0 + $1.value }
        return totalWeight/Double(chartData.count)
        
    }
    
    var selectedStat: HealthMetricType
    var chartData: [HealthMetric]
    
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }
    
    var body: some View {
        VStack {
            NavigationLink(value: selectedStat) {
                HStack{
                    VStack (alignment: .leading){
                        Label("Weight", image: "weightlogo")
                            .font(.title3.bold())
                            .foregroundColor(.purple)
                        Text("Average of 28 days: \(avgWeight.formatted(.number.precision(.fractionLength(1)))) pounds")
                            .font(.caption)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.purple)
                }
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)
            
            Chart {
                if let selectedHealthMetric {
                    RuleMark(x: .value("Selected Metric", selectedHealthMetric.date, unit: .day))
                        .foregroundStyle(Color.secondary.opacity(0.3))
                        .offset(y: -10)
                        .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) { annotationView }
                }
                ForEach(chartData) { weight in
                    AreaMark(x: .value("day", weight.date, unit: .day),
                             yStart: .value("value", weight.value),
                             yEnd: .value("minvalue", minValue))
                    .foregroundStyle(Gradient(colors: [.purple.opacity(0.5), .clear]))
                    
                    LineMark(x: .value("day", weight.date, unit: .day), y: .value("Value", weight.value))
                        .foregroundStyle(Color(.purple))
                        .symbol(.circle)
                }
            }
            .chartXSelection(value: $rawSelectedDate)
            .frame(height: 150)
            .chartYScale(domain: .automatic(includesZero: false))
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .frame(height: 170)
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDay = newValue
            }
            
        }
        
    }
    
    var annotationView: some View {
        VStack(alignment:. leading) {
            Text(selectedHealthMetric?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(1)))
                .fontWeight(.heavy)
                .foregroundStyle(.purple)
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
    WeightLineChart(selectedStat: .weight, chartData: MockData.weights)
}
