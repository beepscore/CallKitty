//
//  AddBlocksVC.swift
//  CallKitty
//
//  Created by Steve Baker on 11/9/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import UIKit

class AddBlocksVC: UIViewController {

    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var numberToGenerateLabel: UILabel!

    var numberDesired = 0

    // MARK: - view lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = NSLocalizedString("ADD_BLOCKS_VC_TITLE", comment: "AddBlocksVC title")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sliderChanged(sender: UISlider) {
        numberDesired = AddBlocksVC.numberToGenerate(exponent: Double(slider.value))
        numberToGenerateLabel.text = String(numberDesired)
    }

    /// - Parameter exponent: used for base 10 exponentiation
    /// - Returns: 10**exponent, limited to range 1 to 100,000
    static func numberToGenerate(exponent: Double) -> Int {

        var exponentLimited = exponent

        let exponentLimitedMin = 0.0
        let exponentLimitedMax = 5.0

        if exponent < exponentLimitedMin {
            exponentLimited = exponentLimitedMin
        } else if exponent > exponentLimitedMax {
            exponentLimited = exponentLimitedMax
        }

        var numberDesired = Int(pow(10, exponentLimited))

        // limit range again because exponentiation is not exact
        let numberDesiredMin = 1
        let numberDesiredMax = 100_000
        
        if numberDesired < numberDesiredMin {
            numberDesired = numberDesiredMin
        } else if numberDesired > numberDesiredMax {
            numberDesired = numberDesiredMax
        }
        return numberDesired
    }

}
