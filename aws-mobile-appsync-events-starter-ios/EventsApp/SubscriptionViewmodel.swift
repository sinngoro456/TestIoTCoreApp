//
//  SubscriptionViewmodel.swift
//  EventsApp
//
//  Created by 川渕悟郎 on 2025/02/09.
//  Copyright © 2025 Dubal, Rohan. All rights reserved.
//

import AWSAppSync
import MapKit
import SwiftUI

class SubscriptionViewModel: ObservableObject {
    // AppSync のクライアント
    private var appSyncClient: AWSAppSyncClient?

    // サブスクリプション ウォッチャー
    private var subscriptionWatcher: AWSAppSyncSubscriptionWatcher<MySubscription>?

    // 監視対象のデータ。View 側で表示する
    @Published var latitude: Double = 35.681_236
    @Published var longitude: Double = 139.767_125
    @Published var velocity: Double = 0.0

    // 地図の表示領域を SwiftUI の Map 用に管理する (iOS 14+)
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 35.681_236, longitude: 139.767_125),
                                               span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

    init() {
        // ここで AppSyncClient を初期化
        do {
            let serviceConfig = try AWSAppSyncServiceConfig()
            let cacheConfig = try AWSAppSyncCacheConfiguration()
            let appSyncConfig = try AWSAppSyncClientConfiguration(appSyncServiceConfig: serviceConfig,
                                                                  cacheConfiguration: cacheConfig)
            self.appSyncClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)

        } catch {
            print("Error init AppSync client:", error)
        }
    }

    func startSubscription() {
        guard let appSyncClient = appSyncClient else { return }

        let subscriptionRequest = MySubscription()
        do {
            subscriptionWatcher = try appSyncClient.subscribe(subscription: subscriptionRequest) { [weak self] result, _, error in
                guard let self = self else { return }
                if let error = error {
                    print("Subscription error:", error.localizedDescription)
                    return
                }

                guard let data = result?.data?.onUpdateTestModel1 else {
                    print("No data received from subscription.")
                    return
                }

                // 新しく受け取ったデータを更新
                DispatchQueue.main.async {
                    self.latitude = data.latitude
                    self.longitude = data.longitude
                    self.velocity = data.velocity

                    // 地図の表示領域（region.center）を更新
                    self.region.center = CLLocationCoordinate2D(latitude: data.latitude,
                                                                longitude: data.longitude)
                }
            }
            print("Subscription started.")
        } catch {
            print("Failed to start subscription:", error)
        }
    }

    deinit {
        subscriptionWatcher?.cancel()
        print("Subscription cancelled.")
    }
}
