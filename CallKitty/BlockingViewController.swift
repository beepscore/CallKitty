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
    @IBOutlet weak var phoneCallerPhoneNumberTextField: UITextField!
    @IBOutlet weak var phoneCallerLabelTextField: UITextField!
    @IBOutlet weak var phoneCallerShouldBlockSwitch: UISwitch!

    var phoneCaller: PhoneCaller? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // when view loads, tab bar item displays this variable "title"
        title = NSLocalizedString("BLOCKING_VC_TITLE", comment: "BlockingViewController title")

        // In storyboard, may leave text "-" to prevent interface builder view from jumping out of position
        phoneCallerPhoneNumberTextField.text = ""

        searchBar.delegate = self
        phoneCallerPhoneNumberTextField.delegate = self
        phoneCallerLabelTextField.delegate = self

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func clearUI() {
        phoneCallerPhoneNumberTextField.text = ""
        phoneCallerLabelTextField.text = ""
        phoneCallerShouldBlockSwitch.setOn(true, animated: true)
    }

    /// dismiss any keyboard, whether presented by searchBar or text field
    func dismissAnyKeyboard() {
        searchBar.endEditing(true)
        phoneCallerPhoneNumberTextField.endEditing(true)
        phoneCallerLabelTextField.endEditing(true)
    }

    @IBAction func shouldBlockSwitchChanged(_ sender: UISwitch) {
        dismissAnyKeyboard()
    }

    @IBAction func handleTap(sender: UITapGestureRecognizer) {
        dismissAnyKeyboard()
    }

    @IBAction func addUpdateButtonTapped(_ sender: Any) {

        dismissAnyKeyboard()

        guard let phoneNumberText = phoneCallerPhoneNumberTextField.text else {
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
        let shouldIdentify = desiredPhoneCallerLabel != ""

        if let unwrappedPhoneCaller = phoneCaller {

            // Note user setting shouldDelete false might overwrite a previously set true.
            // Because user tapped addUpdate button, assume they don't want to delete phoneCaller.
            RealmService.addUpdatePhoneCaller(phoneNumber: unwrappedPhoneCaller.phoneNumber,
                                              label: desiredPhoneCallerLabel,
                                              hasChanges: true,
                                              shouldBlock: phoneCallerShouldBlockSwitch.isOn,
                                              isBlocked: unwrappedPhoneCaller.isBlocked,
                                              shouldIdentify: shouldIdentify,
                                              isIdentified: unwrappedPhoneCaller.isIdentified,
                                              shouldDelete: false,
                                              realm: RealmService.shared.realm)

        } else {
            // this is a new PhoneCaller

            RealmService.addUpdatePhoneCaller(phoneNumber: phoneNumber,
                                              label: desiredPhoneCallerLabel,
                                              hasChanges: true,
                                              shouldBlock: phoneCallerShouldBlockSwitch.isOn,
                                              isBlocked: false,
                                              shouldIdentify: shouldIdentify,
                                              isIdentified: false,
                                              shouldDelete: false,
                                              realm: RealmService.shared.realm)
        }
        // yellow to indicate hasChanges
        view.backgroundColor = UIColor.callKittyPaleYellow()
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {

        dismissAnyKeyboard()

        guard let phoneNumberText = phoneCallerPhoneNumberTextField.text else { return }
        guard let phoneNumber = CXCallDirectoryPhoneNumber(phoneNumberText) else { return }

        RealmService.backgroundDeletePhoneCaller(phoneNumber: phoneNumber)
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
            phoneCallerPhoneNumberTextField.text = String(describing: unwrappedPhoneCaller.phoneNumber)
            phoneCallerLabelTextField.text = unwrappedPhoneCaller.label
        } else {
            clearUI()
        }
    }

}

extension BlockingViewController: UITextFieldDelegate {

    // called when user taps return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // dismiss keyboard
        textField.resignFirstResponder()
        return true
    }

    // // called after resignFirstResponder
    // func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    //     return true
    // }

    // // called after textFieldShouldEndEditing
    // func textFieldDidEndEditing(_ textField: UITextField) {
    // }


}
