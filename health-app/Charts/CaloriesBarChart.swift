//
//  CaloriesBarChart.swift
//  health-app
//
//  Created by Tayfun Sener on 13.08.2024.
//

import SwiftUI
import Charts

struct CaloriesBarChart: View {
    
    @State private var rawSelectedDate: Date?
    
    var selectedStat: HealthMetricType
    var chartData: [HealthMetric]
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        let selectedMetric = chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
        return selectedMetric
    }
    
    var avgCaloryCount: Double {
        guard !chartData.isEmpty else { return 0 }
        let totalCalories = chartData.reduce(0) {$0 + $1.value }
        return totalCalories/Double(chartData.count)
        
    }
    
    var body: some View {
        VStack {
            NavigationLink(value: selectedStat) {
                HStack{
                    VStack (alignment: .leading){
                        Label("Calories", image: "energylogo")
                            .font(.title3.bold())
                            .foregroundColor(.green)
                        Text("Average: \(Int(avgCaloryCount)) kcal")
                            .font(.caption)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.green)
                }
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)
            
            if chartData.isEmpty {
                ChartEmptyView(systemImageName: "chart.bar", title: "No data", description: "There is no calories data from Health App.")
            } else {
                Chart {
                    if let selectedHealthMetric {
                        RuleMark(x: .value("Selected Metric", selectedHealthMetric.date, unit: .day))
                            .foregroundStyle(Color.secondary.opacity(0.3))
                            .offset(y: -10)
                            .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {annotationView}
                    }
                    
                    RuleMark(y: .value("Average", avgCaloryCount))
                        .foregroundStyle(Color.secondary)
                        .lineStyle(.init(lineWidth: 1, dash:[4]))
                    
                    ForEach(chartData) { calories in
                        BarMark(
                            x: .value("Date", calories.date, unit: .day),
                            y: .value("Steps", calories.value)
                        )
                        .foregroundStyle(calories.value > avgCaloryCount ? Color.green.gradient : Color.gray.gradient)
                        .opacity(rawSelectedDate == nil || calories.date == selectedHealthMetric?.date ? 1.0 : 0.3)
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
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
    
    var annotationView: some View {
        VStack(alignment:. leading) {
            Text(selectedHealthMetric?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(0)))
                .fontWeight(.heavy)
                .foregroundStyle(.green)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .green.opacity(0.2), radius: 2, x:2, y:2)
        )
    }
}

#Preview {
    CaloriesBarChart(selectedStat: .calories, chartData: MockData.calories)
}
