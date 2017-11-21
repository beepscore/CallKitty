//
//  AppDelegate.swift
//  CallKitty
//
//  Created by Steve Baker on 11/7/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

/*
 Abstract:
 The application delegate.
 */

import UIKit
import PushKit
import CallKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    var window: UIWindow?
    let callManager = CallKittyCallManager()
    var providerDelegate: ProviderDelegate?

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        providerDelegate = ProviderDelegate(callManager: callManager)

        CXCallDirectoryManager.sharedInstance
            .getEnabledStatusForExtension(withIdentifier: "com.beepscore.CallKitty.CallKittyDirectoryExtension",
                                          completionHandler: {(enabledStatus, error)  -> Void in
                                            if let error = error {
                                                print("getEnabledStatusForExtension", error.localizedDescription)
                                            }
                                            var statusString = ""
                                            switch enabledStatus {
                                            case .unknown:
                                                statusString = "unknown"
                                            case .disabled:
                                                statusString = "disabled"
                                            case .enabled:
                                                statusString = "enabled"
                                            }
                                            print("getEnabledStatusForExtension", statusString)
            })

        CXCallDirectoryManager.sharedInstance.reloadExtension (
            withIdentifier: "com.beepscore.CallKitty.CallKittyDirectoryExtension",
            completionHandler: {(error) -> Void in
                if let error = error {
                    print("reloadExtension", error.localizedDescription)
                    // reloadExtension The operation couldn’t be completed. (com.apple.CallKit.error.calldirectorymanager error 6.)
                    //CXErrorCodeCallDirectoryManagerErrorExtensionDisabled = 6
                    // if get error 6, check Settings / Phone / Call blocking and identification / CallKitty switch on
                }
        })

        return true
    }

    /// Display the incoming call to the user
    func displayIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((Error?) -> Void)? = nil) {
        providerDelegate?.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: completion)
    }

}
