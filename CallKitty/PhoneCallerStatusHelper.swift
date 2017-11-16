//
//  PhoneCallerStatusHelper.swift
//  CallKitty
//
//  Created by Steve Baker on 11/16/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import UIKit

// Add helper methods in a separate class, to keep PhoneCaller realm Object as simple as possible.
// Previously I tried adding these methods as an extension to PhoneCaller,
// but for some reason that gave compiler error couldn't see UIColor extension.
class PhoneCallerStatusHelper: NSObject {

    /// - Returns: a short representation of phoneCaller state
    static func statusString(phoneCaller: PhoneCaller) -> String {
        let flags = "hc" + (phoneCaller.hasChanges ? "1" : "0")
            + " sb" + (phoneCaller.shouldBlock ? "1" : "0")
            + " ib" + (phoneCaller.isBlocked ? "1" : "0")
            + " si" + (phoneCaller.shouldIdentify ? "1" : "0")
            + " ii" + (phoneCaller.isIdentified ? "1" : "0")
            + " sd" + (phoneCaller.shouldDelete ? "1" : "0")
        return flags
    }

    /// - Returns: a color representation of phoneCaller state
    static func statusColor(phoneCaller: PhoneCaller) -> UIColor {
        if phoneCaller.shouldDelete {
            return .lightGray
        }
        if phoneCaller.shouldBlock && phoneCaller.shouldIdentify {
            return .orange
        }
        if phoneCaller.shouldBlock {
            return UIColor.callKittyPaleRed()
        }
        if phoneCaller.shouldIdentify {
            return UIColor.callKittyPaleYellow()
        }
        if phoneCaller.hasChanges {
            return UIColor.callKittyPaleGreen()
        }
        return .white
    }

}
