//
//  UIColor+CallKitty.swift
//  CallKitty
//
//  Created by Steve Baker on 11/12/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import UIKit

extension UIColor {

    // https://stackoverflow.com/questions/24029581/why-no-stored-type-properties-for-classes-in-swift/26867548#26867548
    struct CallKittyColorValues {
        static var pale: CGFloat = 240.0
        static var medium: CGFloat = 180.0
    }

    static func callKittyPaleGreen() -> UIColor {
        return UIColor( red: (CallKittyColorValues.pale/255.0),
                        green: 1.0, blue: CGFloat(CallKittyColorValues.pale/255.0), alpha: 1.0 )
    }

    static func callKittyPaleRed() -> UIColor {
        return UIColor( red: 1.0, green: (CallKittyColorValues.pale/255.0),
                        blue: CGFloat(CallKittyColorValues.pale/255.0), alpha: 1.0 )
    }

    static func callKittyPaleYellow() -> UIColor {
        return UIColor( red: 1.0, green: 1.0,
                        blue: CGFloat(CallKittyColorValues.pale/255.0), alpha: 1.0 )
    }

    static func callKittyPaleOrange() -> UIColor {
        return UIColor( red: 1.0, green: CGFloat(CallKittyColorValues.pale/255.0), blue: 0.0, alpha: 1.0 )
    }

    static func callKittyMediumGreen() -> UIColor {
        return UIColor( red: (CallKittyColorValues.medium/255.0), green: 1.0, blue: CGFloat(CallKittyColorValues.medium/255.0), alpha: 1.0 )
    }

    static func callKittyMediumOrange() -> UIColor {
        return UIColor( red: 1.0, green: CGFloat(CallKittyColorValues.medium/255.0), blue: 0.0, alpha: 1.0 )
    }

    static func callKittyMediumRed() -> UIColor {
        return UIColor( red: 1.0, green: (CallKittyColorValues.medium/255.0), blue: CGFloat(CallKittyColorValues.medium/255.0), alpha: 1.0 )
    }

    static func callKittyMediumYellow() -> UIColor {
        return UIColor( red: 1.0, green: 1.0, blue: CGFloat(CallKittyColorValues.medium/255.0), alpha: 1.0 )
    }
}
