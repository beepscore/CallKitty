//
//  SummaryViewController.swift
//  CallKitty
//
//  Created by Steve Baker on 11/9/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController {

    @IBOutlet private weak var blockingCountLabel: UILabel!
    @IBOutlet private weak var identifyingCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = NSLocalizedString("SUMMARY_VC_TITLE", comment: "SummaryViewController title")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
