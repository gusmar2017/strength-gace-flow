//
//  StrengthGraceFlowApp.swift
//  StrengthGraceFlow
//
//  Created by Gustavo Marquez on 12/21/25.
//

import SwiftUI
import FirebaseCore

@main
struct StrengthGraceFlowApp: App {

    init() {
        FirebaseApp.configure()
    }

    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}
