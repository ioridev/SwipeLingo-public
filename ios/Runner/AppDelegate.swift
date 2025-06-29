import Flutter
import UIKit
import UserNotifications // UserNotificationsをインポート
import receive_sharing_intent // Import the package

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Add this method to handle shared URLs
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      let sharingIntent = SwiftReceiveSharingIntentPlugin.instance
      // Check if the URL is from a share extension or a direct open
      if sharingIntent.hasMatchingSchemePrefix(url: url) {
          return sharingIntent.application(app, open: url, options: options)
      }

      // Handle other URL types if needed
      return super.application(app, open: url, options: options);
  }
}
