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
    @IBOutlet weak var phoneCallerPhoneNumberLabel: UILabel!
    @IBOutlet weak var phoneCallerLabelTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // when view loads, tab bar item displays this variable "title"
        title = NSLocalizedString("BLOCKING_VC_TITLE", comment: "BlockingViewController title")

        searchBar.delegate = self
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

        if let phoneCaller = phoneCaller {
            // show phone number text fields for editing
            phoneCallerPhoneNumberLabel.text = String(describing: phoneCaller.phoneNumber)
            phoneCallerLabelTextField.text = phoneCaller.label
        } else {
            phoneCallerPhoneNumberLabel.text = "not found"
            phoneCallerLabelTextField.text = ""
        }
    }

}
