//
//  CaloriesTodayCard.swift
//  health-app
//
//  Created by Tayfun Sener on 13.08.2024.
//

import SwiftUI

struct CaloriesTodayCard: View {
    
    var chartData: [HealthMetric]
    
    var body: some View {
        
        VStack {
            HStack{
                VStack (alignment: .leading){
                    Label("Calories Burned", image: "calorylogo")
                        .font(.title3.bold())
                        .foregroundColor(.green)
                    Text("\(Int(chartData.last?.value ?? 0)) kcal")
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

#Preview {
    CaloriesTodayCard(chartData: MockData.calories)
}
