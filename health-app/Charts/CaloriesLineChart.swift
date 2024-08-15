//
//  CaloriesLineChart.swift
//  health-app
//
//  Created by Tayfun Sener on 13.08.2024.
//

import SwiftUI
import Charts

struct CaloriesLineChart: View {
    
    @State private var rawSelectedDate: Date?
    
    var selectedStat: HealthMetricType
    var chartData: [HealthMetric]
    
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }
    
    var avgCaloriesCount: Double {
        guard !chartData.isEmpty else { return 0 }
        let totalCalories = chartData.reduce(0) {$0 + $1.value }
        return totalCalories/Double(chartData.count)
        
    }
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        return chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    var body: some View {
        VStack {
            NavigationLink(value: selectedStat) {
                HStack{
                    VStack (alignment: .leading){
                        Label("Calories", image: "energylogo")
                            .font(.title3.bold())
                            .foregroundColor(.green)
                        Text("Average of 28 days: \(avgCaloriesCount.formatted(.number.precision(.fractionLength(1)))) kcal")
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
                ChartEmptyView(systemImageName: "chart.line.downtrend.xyaxis", title: "No data", description: "There is no calories data from Health App.")
            } else {
                Chart {
                    if let selectedHealthMetric {
                        RuleMark(x: .value("Selected Metric", selectedHealthMetric.date, unit: .day))
                            .foregroundStyle(Color.secondary.opacity(0.3))
                            .offset(y: -10)
                            .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) { annotationView }
                    }
                    ForEach(chartData) { calory in
                        AreaMark(x: .value("day", calory.date, unit: .day),
                                 yStart: .value("value", calory.value),
                                 yEnd: .value("minvalue", minValue))
                        .foregroundStyle(Gradient(colors: [.green.opacity(0.5), .clear]))
                        
                        LineMark(x: .value("day", calory.date, unit: .day), y: .value("Value", calory.value))
                            .foregroundStyle(Color(.green))
                            .symbol(.circle)
                    }
                }
                .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                .frame(height: 130)
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
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(1)))
                .fontWeight(.heavy)
                .foregroundStyle(.green)
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
    CaloriesLineChart(selectedStat: .calories, chartData: MockData.calories)
}
