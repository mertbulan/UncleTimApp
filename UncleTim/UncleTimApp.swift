//
//  UncleTimApp.swift
//  UncleTim
//
//  Created by Mert Bulan on 06.12.24.
//

import SwiftUI

@main
struct UncleTimApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Notifications())
        }
    }
}
