//
//  HealthKitPermissionView.swift
//  health-app
//
//  Created by Tayfun Sener on 9.08.2024.
//

import SwiftUI
import HealthKitUI

struct HealthKitPermissionView: View {
    
    @Environment(HealthKitManager.self) private var hkmanager
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingHealthKitPermission = false
    @Binding var hasSeen: Bool
    
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
                isShowingHealthKitPermission = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
        .padding(30)
        .interactiveDismissDisabled()
        .onAppear {
            hasSeen = true
        }
        .healthDataAccessRequest(store: hkmanager.store,
                                 shareTypes: hkmanager.types,
                                 readTypes: hkmanager.types,
                                 trigger: isShowingHealthKitPermission) { result in
            switch result {
            case .success(_):
                dismiss()
            case .failure(_):
                dismiss()
            }
        }
    }
}

#Preview {
    HealthKitPermissionView(hasSeen: .constant(true))
        .environment(HealthKitManager())
}
