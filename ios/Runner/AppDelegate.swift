import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // LocalAI plugin disabled for release
    // let controller = window?.rootViewController as! FlutterViewController
    // if #available(iOS 13.0, *) {
    //   LocalAIPlugin.register(with: registrar(forPlugin: "LocalAIPlugin")!)
    // }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
