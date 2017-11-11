//
//  BlockingViewController.swift
//  CallKitty
//
//  Created by Steve Baker on 11/9/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import UIKit
import CallKit

class BlockingViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!

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

extension BlockingViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        // dismiss keyboard
        searchBar.endEditing(true)

        guard let searchBarText = searchBar.text else { return }
        guard let phoneNumber = CXCallDirectoryPhoneNumber(searchBarText) else { return }

        let phoneCaller = RealmService.getPhoneCaller(phoneNumber: phoneNumber, realm: RealmService.shared.realm)

        if phoneCaller == nil {
            print("not found")
        } else {
            // show phone number text fields for editing
        }
    }

}
