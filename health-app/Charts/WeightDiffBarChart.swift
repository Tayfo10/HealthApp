//
//  WeightDiffBarChart.swift
//  health-app
//
//  Created by Tayfun Sener on 12.08.2024.
//

import SwiftUI
import Charts

struct WeightDiffBarChart: View {
    
    @State private var rawSelectedDate: Date?
    
    var chartData: [WeekdayChartData]
    
    var selectedData: WeekdayChartData? {
        guard let rawSelectedDate else { return nil }
        let selectedMetric = chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
        return selectedMetric
    }
    
    var body: some View {
        
        VStack {
            HStack{
                VStack (alignment: .leading){
                    Label("Average Weight Change", image: "weightlogo")
                        .font(.title3.bold())
                        .foregroundColor(.purple)
                    Text("Per Weekday (Last 28 Days)")
                        .font(.caption)
                }
                Spacer()
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)
    
            Chart {
                if let selectedData {
                    RuleMark(x: .value("Selected Data", selectedData.date, unit: .day))
                        .foregroundStyle(Color.secondary.opacity(0.3))
                        .offset(y: -10)
                        .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {annotationView}
                    
                }
                
                ForEach(chartData) { weightDiff in
                    BarMark(
                        x: .value("Date", weightDiff.date, unit: .day),
                        y: .value("Steps", weightDiff.value)
                    )
                    .foregroundStyle(weightDiff.value >= 0 ? Color.purple.gradient : Color.gray.gradient)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)){
                    AxisValueLabel(format: .dateTime.weekday(), centered: true)
                }
            }
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .frame(height: 200)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
    
    var annotationView: some View {
        VStack(alignment:. leading) {
            Text(selectedData?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            Text(selectedData?.value ?? 0, format: .number.precision(.fractionLength(2)))
                .fontWeight(.heavy)
                .foregroundStyle((selectedData?.value ?? 0) >= 0 ? .purple : .gray)
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
    WeightDiffBarChart(chartData: MockData.weightDiffs)
}
