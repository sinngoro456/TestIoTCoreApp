//
//  GetSpeed.swift
//  SpeedMeter
//
//  Created by 川渕悟郎 on 2025/02/07.
//

import Foundation
import AWSDynamoDB

class GetSpeed {
    let dynamoDB = AWSDynamoDB.default()
    let tableName = "MyGpsMap_users"
    
    func startFetchingUserIDs(interval: TimeInterval = 5.0, completion: @escaping ([String]) -> Void) {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.fetchUserIDs(completion: completion)
        }
    }
    
    private func fetchUserIDs(completion: @escaping ([String]) -> Void) {
        let scanInput = AWSDynamoDBScanInput()
        scanInput?.tableName = tableName
        
        dynamoDB.scan(scanInput!).continueWith { (task: AWSTask<AWSDynamoDBScanOutput>) -> Any? in
            if let error = task.error {
                print("Error fetching user IDs: \(error.localizedDescription)")
                return nil
            }
            
            guard let scanOutput = task.result else {
                print("No result from scan operation")
                return nil
            }
            
            let userIDs = scanOutput.items?.compactMap { item -> String? in
                guard let userIDAttribute = item["user_id"],
                      case .s(let userID) = userIDAttribute else {
                    return nil
                }
                return userID
            } ?? []
            
            DispatchQueue.main.async {
                completion(userIDs)
            }
            
            return nil
        }
    }
}
