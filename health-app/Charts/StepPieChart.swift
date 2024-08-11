//
//  StepPieChart.swift
//  health-app
//
//  Created by Tayfun Sener on 11.08.2024.
//

import SwiftUI
import Charts

struct StepPieChart: View {
    
    var chartData: [WeekdayChartData]
    
    var body: some View {
        
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
            Chart {
                ForEach(chartData) { weekday in
                    SectorMark(angle: .value("average steps", weekday.value),
                               innerRadius: .ratio(0.7),
                               angularInset: 3
                    )
                    .foregroundStyle(.mint.gradient)
                    .cornerRadius(4)
                    
                        
                }
            }
            .frame(height: 240)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        
    }
}

#Preview {
    StepPieChart(chartData: ChartMath.averageWeekdayCount(for: HealthMetric.mockData))
}
