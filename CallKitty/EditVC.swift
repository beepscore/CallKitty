//
//  EditVC.swift
//  CallKitty
//
//  Created by Steve Baker on 11/9/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import UIKit
import CallKit

class EditVC: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var phoneCallerPhoneNumberTextField: UITextField!
    @IBOutlet weak var phoneCallerLabelTextField: UITextField!
    @IBOutlet weak var phoneCallerShouldBlockSwitch: UISwitch!
    @IBOutlet weak var phoneCallerShouldIdentifySwitch: UISwitch!
    @IBOutlet weak var addUpdateButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    var phoneCaller: PhoneCaller? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // when view loads, tab bar item displays this variable "title"
        title = NSLocalizedString("EDIT_VC_TITLE", comment: "EditVC title")

        searchBar.delegate = self
        phoneCallerPhoneNumberTextField.delegate = self
        phoneCallerLabelTextField.delegate = self

        // In storyboard, may leave text "-" to prevent interface builder view from jumping out of position
        phoneCallerPhoneNumberTextField.text = ""

        updateUI()

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
    }

    func updateUI() {
        dismissAnyKeyboard()

        let shouldEnableBlockSwitch = phoneCallerPhoneNumberTextField.text != nil
            && phoneCallerPhoneNumberTextField.text != ""
        phoneCallerShouldBlockSwitch.isEnabled = shouldEnableBlockSwitch

        let shouldEnableIdentifySwitch = phoneCallerPhoneNumberTextField.text != nil
            && phoneCallerPhoneNumberTextField.text != ""
            && phoneCallerLabelTextField.text != nil
            && phoneCallerLabelTextField.text != ""
        phoneCallerShouldIdentifySwitch.isEnabled = shouldEnableIdentifySwitch

        addUpdateButton.isEnabled = shouldEnableBlockSwitch
        deleteButton.isEnabled = shouldEnableIdentifySwitch
    }

    /// dismiss any keyboard, whether presented by searchBar or text field
    func dismissAnyKeyboard() {
        searchBar.endEditing(true)
        phoneCallerPhoneNumberTextField.endEditing(true)
        phoneCallerLabelTextField.endEditing(true)
    }

    @IBAction func shouldBlockSwitchChanged(_ sender: Any) {
        updateUI()
    }

    @IBAction func shouldIdentifySwitchChanged(_ sender: UISwitch) {
        updateUI()
    }

    @IBAction func handleTap(sender: UITapGestureRecognizer) {
        updateUI()
    }

    @IBAction func addUpdateButtonTapped(_ sender: Any) {

        updateUI()

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

        let resolvedShouldIdentify = phoneCallerShouldIdentifySwitch.isOn
            && (desiredPhoneCallerLabel != "")

        if let unwrappedPhoneCaller = phoneCaller {

            // Note user setting shouldDelete false might overwrite a previously set true.
            // Because user tapped addUpdate button, assume they don't want to delete phoneCaller.
            RealmService.backgroundAddUpdatePhoneCaller(phoneNumber: unwrappedPhoneCaller.phoneNumber,
                                                        label: desiredPhoneCallerLabel,
                                                        hasChanges: true,
                                                        shouldBlock: phoneCallerShouldBlockSwitch.isOn,
                                                        isBlocked: unwrappedPhoneCaller.isBlocked,
                                                        shouldIdentify: resolvedShouldIdentify,
                                                        isIdentified: unwrappedPhoneCaller.isIdentified,
                                                        shouldDelete: false) {
                                                            // completion
                                                            let context = CXCallDirectoryExtensionContext()
                                                            // beginRequest calls completeRequest
                                                            CallDirectoryHandler.shared.beginRequest(with: context)
            }

            view.backgroundColor = PhoneCallerStatusHelper.statusColor(phoneCaller: unwrappedPhoneCaller)
        } else {
            // this is a new PhoneCaller
            RealmService.backgroundAddUpdatePhoneCaller(phoneNumber: phoneNumber,
                                                        label: desiredPhoneCallerLabel,
                                                        hasChanges: true,
                                                        shouldBlock: phoneCallerShouldBlockSwitch.isOn,
                                                        isBlocked: false,
                                                        shouldIdentify: resolvedShouldIdentify,
                                                        isIdentified: false,
                                                        shouldDelete: false) {
                                                            // completion
                                                            let context = CXCallDirectoryExtensionContext()
                                                            // beginRequest calls completeRequest
                                                            CallDirectoryHandler.shared.beginRequest(with: context)
            }
         view.backgroundColor = UIColor.callKittyPaleYellow()
        }
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {

        updateUI()

        guard let phoneNumberText = phoneCallerPhoneNumberTextField.text else { return }
        guard let phoneNumber = CXCallDirectoryPhoneNumber(phoneNumberText) else { return }
        guard let phoneCaller = RealmService.getPhoneCaller(phoneNumber: phoneNumber,
                                                            realm: RealmService.shared.realm) else { return }

        // call backgroundAddUpdatePhoneCaller with shouldDelete true
        // TODO: is it better to set hasChanges true, false, or don't care?
        RealmService.backgroundAddUpdatePhoneCaller(phoneNumber: phoneCaller.phoneNumber,
                                                    label: phoneCaller.label,
                                                    hasChanges: true,
                                                    shouldBlock: phoneCaller.shouldBlock,
                                                    isBlocked: phoneCaller.isBlocked,
                                                    shouldIdentify: phoneCaller.shouldIdentify,
                                                    isIdentified: phoneCaller.isIdentified,
                                                    shouldDelete: true) {
                                                        // completion
                                                        let context = CXCallDirectoryExtensionContext()
                                                        // beginRequest calls completeRequest
                                                        CallDirectoryHandler.shared.beginRequest(with: context)
        }
    }

}

extension EditVC: UISearchBarDelegate {

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
            updateUI()
        } else {
            clearUI()
        }
    }

}

extension EditVC: UITextFieldDelegate {

    // called when user taps return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // dismiss keyboard
        textField.resignFirstResponder()
        updateUI()
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        updateUI()
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
