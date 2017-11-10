//
//  BlockingViewController.swift
//  CallKitty
//
//  Created by Steve Baker on 11/9/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import UIKit

class BlockingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // when view loads, tab bar item displays this variable "title"
        title = NSLocalizedString("BLOCKING_VC_TITLE", comment: "BlockingViewController title")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
