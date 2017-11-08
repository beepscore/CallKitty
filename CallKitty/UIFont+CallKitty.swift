/*
	Copyright (C) 2017 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Extension of UIFont for creating monospaced font attributes suitable for displaying increasing call durations
*/

import UIKit
import CoreText

extension UIFont {

    var addingMonospacedNumberAttributes: UIFont {
        let attributes = [
            UIFontDescriptor.AttributeName.featureSettings: [[
                UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
                UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector,
            ]]
        ]
        let fontDescriptorWithAttributes = fontDescriptor.addingAttributes(attributes)
        return UIFont(descriptor: fontDescriptorWithAttributes, size: pointSize)
    }

}
