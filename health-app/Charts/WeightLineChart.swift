//
//  WeightLineChart.swift
//  health-app
//
//  Created by Tayfun Sener on 12.08.2024.
//

import SwiftUI
import Charts


struct WeightLineChart: View {
    
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
                        Text("Average: 72.4kg")
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
            
            
            .frame(height: 130)
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        
    }
}

#Preview {
    WeightLineChart(selectedStat: .weight, chartData: MockData.weights)
}
