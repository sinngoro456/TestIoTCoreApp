//
//  MySubscription.swift
//  EventsApp
//
//  Created by 川渕悟郎 on 2025/02/09.
//  Copyright © 2025 Dubal, Rohan. All rights reserved.
//

import AWSAppSync
import Foundation

public final class MySubscription: GraphQLSubscription {
    // 実際に送る GraphQL subscription の文字列
    public static let operationString = """
    subscription MySubscription {
      onUpdateTest_model(clientId: "test-client") {
        clientId
        latitude
        longitude
        timestamp
        velocity
      }
    }
    """

    // イニシャライザ
    public init() {}

    // 引数がなければ variables は nil のままでOK
    public var variables: GraphQLMap? {
        nil
    }

    // 受信データのマッピング用 (GraphQLSelectionSet)
    public struct Data: GraphQLSelectionSet {
        public static let possibleTypes = ["Subscription"]
        public static let selections: [GraphQLSelection] = [
            GraphQLField("onUpdateTest_model",
                         arguments: ["clientId": "test-client"],
                         type: .object(OnUpdateTestModel1.selections))
        ]

        // スナップショット
        public var snapshot: Snapshot
        public init(snapshot: Snapshot) {
            self.snapshot = snapshot
        }

        // ✅ プロパティ名を変更 (onUpdateTestModel1) して、アンダースコアを使わないようにする
        public var onUpdateTestModel1: OnUpdateTestModel1? {
            guard let fieldSnapshot = snapshot["onUpdateTest_model"] as? Snapshot else {
                // サブスク未発火 or nil ならここは nil
                return nil
            }
            return OnUpdateTestModel1(snapshot: fieldSnapshot)
        }

        // 内部構造: onUpdateTest_model の返却データ
        public struct OnUpdateTestModel1: GraphQLSelectionSet {
            public static let possibleTypes = ["test_model"]
            public static let selections: [GraphQLSelection] = [
                GraphQLField("clientId", type: .nonNull(.scalar(String.self))),
                GraphQLField("latitude", type: .nonNull(.scalar(Double.self))),
                GraphQLField("longitude", type: .nonNull(.scalar(Double.self))),
                GraphQLField("timestamp", type: .nonNull(.scalar(Int.self))),
                GraphQLField("velocity", type: .nonNull(.scalar(Double.self)))
            ]

            public var snapshot: Snapshot
            public init(snapshot: Snapshot) {
                self.snapshot = snapshot
            }

            // 各フィールドを安全に取り出す (force cast → guard let に変更)
            public var clientId: String {
                guard let value = snapshot["clientId"] as? String else {
                    fatalError("Expected 'clientId' to be String, but found nil or invalid type.")
                }
                return value
            }

            public var latitude: Double {
                guard let value = snapshot["latitude"] as? Double else {
                    fatalError("Expected 'latitude' to be Double, but found nil or invalid type.")
                }
                return value
            }

            public var longitude: Double {
                guard let value = snapshot["longitude"] as? Double else {
                    fatalError("Expected 'longitude' to be Double, but found nil or invalid type.")
                }
                return value
            }

            public var timestamp: Int {
                guard let value = snapshot["timestamp"] as? Int else {
                    fatalError("Expected 'timestamp' to be Int, but found nil or invalid type.")
                }
                return value
            }

            public var velocity: Double {
                guard let value = snapshot["velocity"] as? Double else {
                    fatalError("Expected 'velocity' to be Double, but found nil or invalid type.")
                }
                return value
            }
        }
    }
}
