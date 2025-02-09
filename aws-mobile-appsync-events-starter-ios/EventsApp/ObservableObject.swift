//
//  ObservableObject.swift
//  EventsApp
//
//  Created by 川渕悟郎 on 2025/02/09.
//  Copyright © 2025 Dubal, Rohan. All rights reserved.
//

import AWSAppSync
import MapKit
import SwiftUI

class SharedEventData: ObservableObject {
    // AppSync クライアント (シングルトンなどで確保してもよい)
    private var appSyncClient: AWSAppSyncClient? = AppSyncManager.shared.client

    // イベント情報
    @Published var event: Event?
    @Published var comments: [Event.Comment.Item?] = []

    // 地図表示用
    @Published var latitude: Double = 35.681_236
    @Published var longitude: Double = 139.767_125
    @Published var velocity: Double = 0.0
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 35.681_236, longitude: 139.767_125),
                                               span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

    // サブスクリプションウォッチャー
    private var subscriptionWatcher: AWSAppSyncSubscriptionWatcher<MySubscription>?
    private var newCommentsWatcher: AWSAppSyncSubscriptionWatcher<NewCommentOnEventSubscription>?

    // 初期化
    init() {}

    // イベントを取得 (例: IDを指定して)
    func fetchEvent(id: String) {
        guard let client = appSyncClient else { return }

        let query = GetEventQuery(id: id)
        client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching event: \(error)")
                return
            }
            guard let event = result?.data?.getEvent?.fragments.event else {
                print("No event data found.")
                return
            }
            DispatchQueue.main.async {
                self.event = event
                self.comments = event.comments?.items ?? []
            }
        }
    }

    // イベントのサブスクリプション (UI共通)
    func startEventSubscription(clientId: String = "test-client") {
        guard let client = appSyncClient else { return }
        let subscriptionRequest = MySubscription()

        do {
            subscriptionWatcher = try client.subscribe(subscription: subscriptionRequest) { [weak self] result, _, error in
                guard let self = self else { return }
                if let error = error {
                    print("Subscription error: \(error.localizedDescription)")
                    return
                }
                guard let data = result?.data?.onUpdateTestModel1 else {
                    print("No data received from subscription.")
                    return
                }
                // 次のランループで状態を更新する
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.latitude = data.latitude
                    self.longitude = data.longitude
                    self.velocity = data.velocity
                    self.region.center = CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude)
                }
            }
            print("Event subscription started.")
        } catch {
            print("Failed to start subscription: \(error)")
        }
    }

    // コメントサブスクなど、EventDetailsViewController で使っていたロジックもまとめる
    func startCommentsSubscription(eventId: String) {
        guard let client = appSyncClient else { return }

        let subscriptionRequest = NewCommentOnEventSubscription(eventId: eventId)
        do {
            newCommentsWatcher = try client.subscribe(subscription: subscriptionRequest) {
                [weak self] result, _, error in
                guard let self = self else { return }
                if let error = error {
                    print("Comment subscription error: \(error)")
                    return
                }
                guard let data = result?.data?.subscribeToEventComments else {
                    print("No comment data.")
                    return
                }

                DispatchQueue.main.async {
                    // 既存の comments に追加
                    let newCommentData = CommentOnEventMutation.Data.CommentOnEvent(eventId: data.eventId,
                                                                                    content: data.content,
                                                                                    commentId: data.commentId,
                                                                                    createdAt: data.createdAt)
                    let newCommentObj = Event.Comment.Item(snapshot: newCommentData.snapshot)
                    self.comments.append(newCommentObj)
                }
            }
            print("Comments subscription started.")
        } catch {
            print("Failed to start comments subscription: \(error)")
        }
    }

    deinit {
        subscriptionWatcher?.cancel()
        newCommentsWatcher?.cancel()
    }
}
