//
//  HealthKitPermissionView.swift
//  health-app
//
//  Created by Tayfun Sener on 9.08.2024.
//

import SwiftUI

struct HealthKitPermissionView: View {
    
    var description = """

    This app displays your step, weight and calory data in interactive charts.
    
    New data regarding these metrics may also be added to Apple Health from this app. Your data is private and secure.

    """
    
    var body: some View {
        VStack (spacing: 130){
            VStack (alignment: .leading){
                Image("applehealthicon")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .shadow(color: .gray.opacity(0.4), radius:16)
                    .padding(.bottom, 30)
                Text("Apple Health Integration")
                    .font(.title2.bold())
                Text(description)
            }
            Button("Connect Apple Health") {
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
        .padding(30)
    }
}

#Preview {
    HealthKitPermissionView()
}
