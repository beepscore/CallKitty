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
    @IBOutlet weak var phoneCallerShouldBlockSwitch: UISwitch!

    var phoneCaller: PhoneCaller? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // when view loads, tab bar item displays this variable "title"
        title = NSLocalizedString("BLOCKING_VC_TITLE", comment: "BlockingViewController title")

        // In storyboard, leave text "-" to prevent interface builder view from jumping out of position
        phoneCallerPhoneNumberLabel.text = ""

        searchBar.delegate = self

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func clearUI() {
        phoneCallerPhoneNumberLabel.text = ""
        phoneCallerLabelTextField.text = ""
        phoneCallerShouldBlockSwitch.setOn(true, animated: true)
    }

    @IBAction func shouldBlockSwitchChanged(_ sender: UISwitch) {
        // do nothing
    }

    @IBAction func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            // dismiss keyboard presented by searchBar
            searchBar.endEditing(true)
            // dismiss keyboard presented by text field
            phoneCallerLabelTextField.endEditing(true)
        }
    }

    @IBAction func addUpdateButtonTapped(_ sender: Any) {

        guard let phoneNumberText = phoneCallerPhoneNumberLabel.text else {
            clearUI()
            return
        }

        // TODO: sanitize user input before converting to phone number
        guard let phoneNumber = CXCallDirectoryPhoneNumber(phoneNumberText) else {
            clearUI()
            return
        }

        phoneCaller = RealmService.getPhoneCaller(phoneNumber: phoneNumber, realm: RealmService.shared.realm)

        let desiredPhoneCallerLabel = phoneCallerLabelTextField.text != nil ? phoneCallerLabelTextField.text! : ""

        if let unwrappedPhoneCaller = phoneCaller {

            RealmService.addUpdatePhoneCaller(phoneNumber: unwrappedPhoneCaller.phoneNumber,
                                              label: desiredPhoneCallerLabel,
                                              shouldBlock: phoneCallerShouldBlockSwitch.isOn,
                                              realm: RealmService.shared.realm)
        } else {

            RealmService.addUpdatePhoneCaller(phoneNumber: phoneNumber,
                                              label: desiredPhoneCallerLabel,
                                              shouldBlock: phoneCallerShouldBlockSwitch.isOn,
                                              realm: RealmService.shared.realm)
        }

        if phoneCallerShouldBlockSwitch.isOn {
            // TODO: Consider define a theme constant for this color
            view.backgroundColor = UIColor( red: 1.0, green: CGFloat(220/255.0), blue: CGFloat(220/255.0), alpha: 1.0 )
        } else {
            view.backgroundColor = .white
        }
    }
}

extension BlockingViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        // dismiss keyboard
        searchBar.endEditing(true)

        guard let searchBarText = searchBar.text else {
            clearUI()
            return
        }
        // TODO: sanitize user input before converting to phone number
        guard let phoneNumber = CXCallDirectoryPhoneNumber(searchBarText) else {
            clearUI()
            return
        }

        phoneCaller = RealmService.getPhoneCaller(phoneNumber: phoneNumber, realm: RealmService.shared.realm)

        if let unwrappedPhoneCaller = phoneCaller {
            // show phone number text fields for editing
            phoneCallerPhoneNumberLabel.text = String(describing: unwrappedPhoneCaller.phoneNumber)
            phoneCallerLabelTextField.text = unwrappedPhoneCaller.label
        } else {
            clearUI()
        }
    }

}
