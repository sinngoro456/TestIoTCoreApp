//
//  GetSpeed.swift
//  SpeedMeter
//
//  Created by 川渕悟郎 on 2025/02/07.
//
import Foundation
import AWSAPIGateway
import Alamofire

class SpeedMonitor {
    private let apiClient: AWSAPIGatewayClient
    private let apiKey: String
    private let endpointURL: URL
    
    init(apiKey: String, endpointURL: URL) {
        self.apiKey = apiKey
        self.endpointURL = endpointURL
        
        let configuration = AWSServiceConfiguration(
            region: .USEast1,
            credentialsProvider: AWSAnonymousCredentialsProvider()
        )
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        self.apiClient = AWSAPIGatewayClient.default()
    }
    
    func fetchSpeed(completion: @escaping (Double?) -> Void) {
        let headers: HTTPHeaders = [
            "x-api-key": apiKey,
            "Content-Type": "application/json"
        ]
        
        AF.request(endpointURL, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any],
                   let speed = json["速さ"] as? Double {
                    completion(speed)
                } else {
                    completion(nil)
                }
            case .failure(let error):
                print("エラー: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func startMonitoring(interval: TimeInterval = 1.0) {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.fetchSpeed { speed in
                if let speed = speed {
                    print("現在の速さ: \(speed)")
                    // ここで速度を使用して必要な処理を行う
                }
            }
        }
    }
}

// 使用例
let apiKey = "あなたのAPIキー"
let endpointURL = URL(string: "https://あなたのAPIエンドポイント")!
let speedMonitor = SpeedMonitor(apiKey: apiKey, endpointURL: endpointURL)
speedMonitor.startMonitoring()
