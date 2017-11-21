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

        CallDirectoryManagerUtils.getEnabledStatusForExtension()
        CallDirectoryManagerUtils.reloadExtension()

        return true
    }

    /// Display the incoming call to the user
    func displayIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((Error?) -> Void)? = nil) {
        providerDelegate?.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: completion)
    }

}
