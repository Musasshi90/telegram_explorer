import Flutter
import UIKit
import FileBrowser


public class SwiftTelegramExplorerPlugin: NSObject, FlutterPlugin, UIDocumentPickerDelegate {
    var result: FlutterResult?;
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "telegram_explorer", binaryMessenger: registrar.messenger())
        let instance = SwiftTelegramExplorerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getPlatformVersion" {
            result("iOS " + UIDevice.current.systemVersion)
        }
        else if call.method == "openBrowser" {
            //            let fileBrowser = FileBrowser()
            //            UIApplication.shared.keyWindow?.rootViewController?.present(fileBrowser, animated: true, completion: nil)
            //            fileBrowser.didSelectFile = { (file: FBFile) -> Void in
            //                result(file.filePath)
            //            }
            
            let controller = UIDocumentPickerViewController(
                documentTypes: [], // choose your desired documents the user is allowed to select
                in: .import // choose your desired UIDocumentPickerMode
            )
            controller.allowsMultipleSelection = false
            controller.delegate = self
            controller.modalPresentationStyle = .overFullScreen
            self.result = result
            if #available(iOS 11.0, *) {
                controller.allowsMultipleSelection = false
            }
            // e.g. present UIDocumentPickerViewController via your current UIViewController
            UIApplication.shared.keyWindow?.rootViewController?.present(
                controller,
                animated: true,
                completion: nil
            )
        }
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard self.result != nil else {
            return
        }
        guard let myURL = urls.first else {
            return
        }
        self.result!(myURL.path)
        self.result = nil
        print("import result : \(myURL)")
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        guard self.result != nil else {
            return
        }
        guard url.startAccessingSecurityScopedResource() else {
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        self.result!(url.path)
        self.result = nil
    }
}
