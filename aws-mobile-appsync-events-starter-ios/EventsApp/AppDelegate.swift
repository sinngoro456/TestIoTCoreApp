import AWSAppSync
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var appSyncClient: AWSAppSyncClient?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            let serviceConfig = try AWSAppSyncServiceConfig() // awsconfiguration.jsonを読み込む
            print("API URL:", serviceConfig.endpoint)
            print("Region :", serviceConfig.region.rawValue)

            let cacheConfiguration = try AWSAppSyncCacheConfiguration()
            let appSyncConfig = try AWSAppSyncClientConfiguration(appSyncServiceConfig: AWSAppSyncServiceConfig(),
                                                                  cacheConfiguration: cacheConfiguration)
            appSyncClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)

            // キャッシュキー設定（今回はほとんど使いませんが残してOK）
            appSyncClient?.apolloClient?.cacheKeyForObject = { $0["id"] }

            print("AppSyncClient initialized.")
        } catch {
            print("Error initializing AppSync client. \(error)")
        }

        return true
    }
}
