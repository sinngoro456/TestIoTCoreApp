//
//  AppSyncManager.swift
//  EventsApp
//
//  Created by 川渕悟郎 on 2025/02/09.
//  Copyright © 2025 Dubal, Rohan. All rights reserved.
//

import AWSAppSync
import Foundation

class AppSyncManager {
    static let shared = AppSyncManager()
    var client: AWSAppSyncClient?

    private init() {
        do {
            let serviceConfig = try AWSAppSyncServiceConfig()
            let cacheConfig = try AWSAppSyncCacheConfiguration()
            let appSyncConfig = try AWSAppSyncClientConfiguration(appSyncServiceConfig: serviceConfig,
                                                                  cacheConfiguration: cacheConfig)
            self.client = try AWSAppSyncClient(appSyncConfig: appSyncConfig)
        } catch {
            print("Error initializing AppSync client: \(error)")
        }
    }
}
