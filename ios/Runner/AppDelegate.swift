import UIKit
import Flutter
import AVFAudio

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      let micChannel = FlutterMethodChannel(
        name: "kai/mic_input",
        binaryMessenger: controller.binaryMessenger
      )
      micChannel.setMethodCallHandler { call, result in
        switch call.method {
        case "selectPrimaryMic":
          result(AppDelegate.selectBottomMic())
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return result
  }

  /// Prefers the iPhone's bottom-oriented built-in mic (the primary
  /// voice/speech mic) over the top mic near the front camera / Dynamic
  /// Island, which iOS can select by default and which picks up more
  /// handling/breath noise for a phone held normally at the mouth. Neither
  /// AVAudioSession's category/mode nor the `record` Flutter plugin expose
  /// per-data-source mic selection, so this has to go through AVAudioSession
  /// directly. No-op (returns false) on devices without a selectable
  /// data source list; the OS default then applies.
  private static func selectBottomMic() -> Bool {
    let session = AVAudioSession.sharedInstance()
    guard let builtInMic = session.availableInputs?.first(where: { $0.portType == .builtInMic })
    else {
      return false
    }
    guard let dataSources = builtInMic.dataSources,
      let bottom = dataSources.first(where: { $0.orientation == .bottom })
    else {
      // ponytail: no bottom-oriented data source reported (older device or
      // single-mic hardware) — just make sure the built-in mic is preferred.
      try? session.setPreferredInput(builtInMic)
      return false
    }
    do {
      try builtInMic.setPreferredDataSource(bottom)
      try session.setPreferredInput(builtInMic)
      return true
    } catch {
      return false
    }
  }
}
