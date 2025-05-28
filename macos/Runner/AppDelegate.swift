import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Register the LLMFarm plugin
    let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
    LLMFarmFlutterPlugin.register(with: registrar(forPlugin: "LLMFarmFlutterPlugin"))
    
    super.applicationDidFinishLaunching(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
