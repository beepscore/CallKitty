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
    var results: Results<PhoneCaller>?
    var notificationToken: NotificationToken?

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
        results = realmService.realm.objects(PhoneCaller.self)

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
        identifyingCountLabel.text = String(RealmService.getAllPhoneCallersShouldIdentifySortedCount(realm: realmService.realm))
    }

}
