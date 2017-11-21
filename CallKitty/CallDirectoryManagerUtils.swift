//
//  CallDirectoryManagerUtils.swift
//  CallKitty
//
//  Created by Steve Baker on 11/20/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import Foundation
import CallKit

class CallDirectoryManagerUtils {

    // Reference Apple CXErrorCodeCallDirectoryManagerError
//    typedef enum CXErrorCodeCallDirectoryManagerError : NSInteger {
//        CXErrorCodeCallDirectoryManagerErrorUnknown = 0,
//        CXErrorCodeCallDirectoryManagerErrorNoExtensionFound = 1,
//        CXErrorCodeCallDirectoryManagerErrorLoadingInterrupted = 2,
//        CXErrorCodeCallDirectoryManagerErrorEntriesOutOfOrder = 3,
//        CXErrorCodeCallDirectoryManagerErrorDuplicateEntries = 4,
//        CXErrorCodeCallDirectoryManagerErrorMaximumEntriesExceeded = 5,
//        CXErrorCodeCallDirectoryManagerErrorExtensionDisabled = 6,
//        CXErrorCodeCallDirectoryManagerErrorCurrentlyLoading = 7,
//        CXErrorCodeCallDirectoryManagerErrorUnexpectedIncrementalRemoval = 8
//    } CXErrorCodeCallDirectoryManagerError;

    static let extensionIdentifier = "com.beepscore.CallKitty.CallKittyDirectoryExtension"

    class func getEnabledStatusForExtension() {
        CXCallDirectoryManager.sharedInstance
            .getEnabledStatusForExtension(withIdentifier: extensionIdentifier,
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
    }

    class func reloadExtension() {
        CXCallDirectoryManager.sharedInstance.reloadExtension (
            withIdentifier: extensionIdentifier,
            completionHandler: {(error) -> Void in
                if let error = error {
                    print("reloadExtension", error.localizedDescription)
                    // reloadExtension The operation couldn’t be completed. (com.apple.CallKit.error.calldirectorymanager error 6.)
                    //CXErrorCodeCallDirectoryManagerErrorExtensionDisabled = 6
                    // if get error 6, check Settings / Phone / Call blocking and identification / CallKitty switch on
                }
        })
    }

}
