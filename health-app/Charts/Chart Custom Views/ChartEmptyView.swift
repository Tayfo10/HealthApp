//
//  ChartEmptyView.swift
//  health-app
//
//  Created by Tayfun Sener on 14.08.2024.
//

import SwiftUI

struct ChartEmptyView: View {
    
    let systemImageName: String
    let title: String
    let description: String
    
    var body: some View {
        ContentUnavailableView {
            Image(systemName: systemImageName )
                .resizable()
                .frame(width: 32, height: 32)
            
                .padding(.bottom, 8)
            Text(title)
                .font(.callout.bold())
            Text(description)
                .font(.footnote)
        }
        .foregroundStyle(.secondary)
        .offset(y: -12)
        
    }
}

#Preview {
    ChartEmptyView(systemImageName: "chart.bar", title: "No data", description: "There is no data.")
}
