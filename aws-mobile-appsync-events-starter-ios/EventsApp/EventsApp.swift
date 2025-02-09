//
//  EventsApp.swift
//  EventsApp
//
//  Created by 川渕悟郎 on 2025/02/09.
//  Copyright © 2025 Dubal, Rohan. All rights reserved.
//

import AWSAppSync
import SwiftUI

@main
struct EventsApp: App {
    @StateObject private var eventData = SharedEventData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(eventData)
        }
    }
}
