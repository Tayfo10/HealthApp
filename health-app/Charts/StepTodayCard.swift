//
//  StepTodayCard.swift
//  health-app
//
//  Created by Tayfun Sener on 11.08.2024.
//

import SwiftUI

struct StepTodayCard: View {
    
    var chartData: [HealthMetric]
    var body: some View {
        
        if chartData.isEmpty {
            VStack {
                ChartEmptyView(systemImageName: "swiftdata", title: "No data", description: "There is no step count data from Health App.")
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        } else {
            VStack {
                HStack{
                    VStack (alignment: .leading){
                        Label("Steps", image: "figure.walk.motion")
                            .font(.title3.bold())
                            .foregroundColor(.mint)
                        Text("\(Int(chartData.last?.value ?? 0))")
                            .font(.title2.bold())
                            .foregroundStyle(.black)
                    }
                    Spacer()
                    Text("Today")
                }
                .foregroundStyle(.secondary)
                .padding(.bottom, 12)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
            
        }
    }
}

#Preview {
    StepTodayCard(chartData: MockData.steps)
}
