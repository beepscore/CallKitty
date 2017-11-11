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

    var phoneCaller: PhoneCaller? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // when view loads, tab bar item displays this variable "title"
        title = NSLocalizedString("BLOCKING_VC_TITLE", comment: "BlockingViewController title")

        searchBar.delegate = self

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func shouldBlockSwitchChanged(_ sender: UISwitch) {

        guard let unwrappedPhoneCaller = phoneCaller else { return }

        RealmService.addUpdatePhoneCaller(phoneNumber: unwrappedPhoneCaller.phoneNumber,
                                          label: unwrappedPhoneCaller.label,
                                          shouldBlock: sender.isOn,
                                          realm: RealmService.shared.realm)

        if unwrappedPhoneCaller.shouldBlock {
            // TODO: Consider define a theme constant for this color
            view.backgroundColor = UIColor( red: 1.0, green: CGFloat(220/255.0), blue: CGFloat(220/255.0), alpha: 1.0 )
        } else {
            view.backgroundColor = .white
        }
    }

    @IBAction func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            // dismiss keyboard
            searchBar.endEditing(true)
        }
    }
}

extension BlockingViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        // dismiss keyboard
        searchBar.endEditing(true)

        guard let searchBarText = searchBar.text else { return }
        guard let phoneNumber = CXCallDirectoryPhoneNumber(searchBarText) else { return }

        phoneCaller = RealmService.getPhoneCaller(phoneNumber: phoneNumber, realm: RealmService.shared.realm)

        if let unwrappedPhoneCaller = phoneCaller {
            // show phone number text fields for editing
            phoneCallerPhoneNumberLabel.text = String(describing: unwrappedPhoneCaller.phoneNumber)
            phoneCallerLabelTextField.text = unwrappedPhoneCaller.label
        } else {
            phoneCallerPhoneNumberLabel.text = "not found"
            phoneCallerLabelTextField.text = ""
        }
    }

}
