//
//  MySubscriptionViewController.swift
//  EventsApp
//
//  Created by 川渕悟郎 on 2025/02/09.
//  Copyright © 2025 Dubal, Rohan. All rights reserved.
//

import AWSAppSync
import Foundation
import MapKit
import UIKit

class MySubscriptionViewController: UIViewController {
    // 3つのラベルをStoryboardで用意し、IBOutletを紐づける
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var velocityLabel: UILabel!
    @IBOutlet var mapView: MKMapView!

    // AppSyncクライアント
    var appSyncClient: AWSAppSyncClient?

    // サブスクリプションのウォッチャーを保持しておく
    var subscriptionWatcher: AWSAppSyncSubscriptionWatcher<MySubscription>?

    override func viewDidLoad() {
        super.viewDidLoad()
        appSyncClient = AppSyncManager.shared.client

        // 例: 東京駅周辺に地図を移動
        let coordinate = CLLocationCoordinate2D(latitude: 35.681_236, longitude: 139.767_125)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        // サブスク開始
        startSubscription()
    }

    func startSubscription() {
        let subscriptionRequest = MySubscription() // 引数不要の場合はこれでOK

        do {
            // 購読開始: resultHandler の中で新データを受け取る
            subscriptionWatcher = try appSyncClient?.subscribe(subscription: subscriptionRequest) {
                [weak self] result, _, error in

                guard let self = self else { return }

                if let error = error {
                    print("Subscription error: \(error.localizedDescription)")
                    return
                }

                // 新データを取り出す
                guard let data = result?.data?.onUpdateTestModel1 else {
                    print("No data received from subscription.")
                    return
                }

                // 受け取った値をUIに反映
                DispatchQueue.main.async {
                    self.latitudeLabel.text = "\(data.latitude)"
                    self.longitudeLabel.text = "\(data.longitude)"
                    self.velocityLabel.text = "\(data.velocity)"
                }
            }

            print("Subscription started.")

        } catch {
            print("Failed to start subscription: \(error)")
        }
    }

    // 画面破棄時には購読を解除
    deinit {
        subscriptionWatcher?.cancel()
        print("Subscription cancelled.")
    }
}
