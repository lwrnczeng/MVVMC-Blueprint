//
//  MVVMCAppApp.swift
//  MVVMCApp
//
//  Created by Lawrence Zeng on 2026-08-13.
//

import SwiftUI
import SwiftData
import MVVMCBlueprint
import ZafinAIAgentBlueprint

@main
struct MVVMCAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainDemoContainerView()
        }
        .modelContainer(sharedModelContainer)
    }
}

struct MainDemoContainerView: View {
    var body: some View {
        TabView {
            ZafinAIAgentChatView()
                .tabItem {
                    Label("Zafin AI Agent", systemImage: "sparkles.bubble.fill")
                }
            
            CheckoutContainerView()
                .tabItem {
                    Label("MVVM-C Checkout", systemImage: "cart.fill")
                }
            
                
        }
    }
}
