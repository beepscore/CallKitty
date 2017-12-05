//
//  SummaryViewController.swift
//  CallKitty
//
//  Created by Steve Baker on 11/9/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

import UIKit
import RealmSwift

class SummaryViewController: UIViewController {

    let realmService = RealmService.shared
    // notificationToken to observe changes from the Realm
    var notificationToken: NotificationToken?
    var realm: Realm!

    var results: Results<PhoneCaller>?

    @IBOutlet private weak var blockingCountLabel: UILabel!
    @IBOutlet private weak var identifyingCountLabel: UILabel!

    // MARK: - view lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = NSLocalizedString("SUMMARY_VC_TITLE", comment: "SummaryViewController title")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // call observeResults here instead of in viewDidLoad, because viewWillDisappear stops observing
        observeResults()
        updateUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // avoid warning ~view not in hierarchy. Wait until viewDidAppear before attempt to present alert.
        // https://stackoverflow.com/questions/26022756/warning-attempt-to-present-on-whose-view-is-not-in-the-window-hierarchy-s#26023209
        if RealmService.shared.username == "" && RealmService.shared.password == "" {
            // TODO: consider improve conditional check if logged in
            getUsernameAndPasswordAndSetupRealm()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // stop update notifications. stop was renamed to invalidate
        notificationToken?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: -

    func observeResults() {
        guard let aRealm = RealmService.aRealm() else { return }
        results = aRealm.objects(PhoneCaller.self)

        // Set results notification block
        // block is called every time the realm collection changes
        // use capture list [weak self] to avoid potential retain cycles
        notificationToken = results?.observe { [weak self] (changes: RealmCollectionChange) in
            // Swift switch cases don't implicitly fall through, don't need break
            // https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/ControlFlow.html
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self?.updateUI()
            case .update(_, _, _, _):
                self?.updateUI()
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
            }
        }
    }

    func updateUI() {
        blockingCountLabel.text = String(RealmService.getAllPhoneCallersIsBlockedSortedCount(realm: realmService.realm))
        identifyingCountLabel.text = String(RealmService.getAllPhoneCallersIsIdentifiedSortedCount(realm: realmService.realm))
    }

    // MARK: - connect to realm object server
    // TODO: consider refactor move parts to RealmService

    func getUsernameAndPasswordAndSetupRealm() {
        let alertController = UIAlertController(title: "Login", message: "", preferredStyle: .alert)

        var usernameTextField: UITextField!
        var passwordTextField: UITextField!

        alertController.addTextField { textField in
            usernameTextField = textField
            textField.placeholder = "User Name"
        }

        alertController.addTextField { textField in
            passwordTextField = textField
            textField.placeholder = "Password"
        }

        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{ _ in
            // nil coalescing operator
            RealmService.shared.username = usernameTextField.text ?? ""
            RealmService.shared.password = passwordTextField.text ?? ""

            self.setupRealm()
        }))

        present(alertController, animated: true, completion: nil)
    }

    func setupRealm() {

        // if username account doesn't exist, must call with register true
//        SyncUser.logIn(with: .usernamePassword(username: RealmService.shared.username,
//                                               password: RealmService.shared.password,
//                                               register: true),

        // if username account exists, must call with register false
        // Log in existing user with username and password
        // TODO: Reference Realm sample code RealmTasks iOS login() to improve this code
        SyncUser.logIn(with: .usernamePassword(username: RealmService.shared.username,
                                               password: RealmService.shared.password,
                                               register: false),
                       server: Constants.syncAuthURL) { user, error in
                        guard let _ = user else {
                            fatalError(String(describing: error))
                        }

                        DispatchQueue.main.async {
                            // TODO: consider use a capture list to reduce risk of retain cycle
                            self.observeResults()
                            // CallDirectoryManagerUtils.reloadExtension()
                        }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }

}
