//
//  LongTableViewController.swift
//  CallKitty
//
//  Created by Steve Baker on 11/10/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//
//  Reference: https://github.com/beepscore/LongTable

import UIKit
import RealmSwift

class LongTableViewController: UITableViewController {

    let realmService = RealmService.shared
    var results: Results<PhoneCaller>?
    var notificationToken: NotificationToken?

    var numSections = 1

    // MARK: - view lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Long Table"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // call observeResults here instead of in viewDidLoad, because viewWillDisappear stops observing
        observeResults()
        tableView.reloadData()
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
        results = realmService.realm.objects(PhoneCaller.self).sorted(byKeyPath: PhoneCaller.PropertyStrings.phoneNumber.rawValue)

        // Set results notification block
        // block is called every time the realm collection changes
        // use capture list [weak self] to avoid potential retain cycles
        notificationToken = results?.observe { [weak self] (changes: RealmCollectionChange) in

            // Swift switch cases don't implicitly fall through, don't need break
            // https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/ControlFlow.html
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self?.tableView.reloadData()
            case .update(_, _, _, _):
                self?.tableView.reloadData()
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsCount(results: results)
    }

    func sectionsCount(results: Results<PhoneCaller>?) -> Int {
        guard let results = results else { return 1 }

        var sections = 1

        switch results.count {
        case 0...100:
            sections = 1
        case 101...1000:
            sections = 20
        default:
            sections = 50
        }
        return sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let results = results else { return 0 }
        let numRows = results.count / sectionsCount(results: results)
        return numRows
    }

    /// - Returns: array of phone number strings approximately in each section
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var titles = [String]()
        if results == nil || results?.count == 0 {
            return titles
        }
        let secCount = sectionsCount(results: results)
        for section in 0..<secCount {
            let approximateRow = Int((Double(section) / Double(secCount)) * Double((results?.count)!))

            let approximatePhoneNumber = results![approximateRow].phoneNumber
            let approximatePhoneString = String(approximatePhoneNumber)

            titles.append(approximatePhoneString)
            // alternatively can show prefix
            //let phoneStart = String(approximatePhoneString.prefix(6))
            //titles.append(phoneStart)
        }
        return titles
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        guard let results = results else { return cell }

        let index = itemIndex(indexPath: indexPath)
        let phoneCaller = results[index]

        cell.textLabel?.text = String(phoneCaller.phoneNumber)
        cell.detailTextLabel?.text = phoneCaller.label
            + " " + LongTableViewController.statusString(phoneCaller: phoneCaller)

        // set background color for diagnostics during development
        cell.backgroundColor = LongTableViewController.statusColor(phoneCaller: phoneCaller)

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            guard let phoneCaller = results?[indexPath.row] else { return }

            // call addUpdatePhoneCaller with shouldDelete true
            // TODO: is it better to set hasChanges true, false, or don't care?
            RealmService.addUpdatePhoneCaller(phoneNumber: phoneCaller.phoneNumber,
                                              label: phoneCaller.label,
                                              hasChanges: true,
                                              shouldBlock: phoneCaller.shouldBlock,
                                              isBlocked: phoneCaller.isBlocked,
                                              shouldIdentify: phoneCaller.shouldIdentify,
                                              isIdentified: phoneCaller.isIdentified,
                                              shouldDelete: true,
                                              realm: RealmService.shared.realm)
        }
    }

    /// for generality, handles sections of differing lengths
    func itemIndex(indexPath: IndexPath) -> Int {

        var index: Int = 0
        if indexPath.section > 0 {
            // in previous sections, add all rows in section
            for section in 0..<indexPath.section {
                index += tableView(tableView, numberOfRowsInSection: section)
            }
        }

        // in current section, add rows up to current row
        index += indexPath.row

        return index
    }

    /// - Returns: a short representation of phoneCaller state
    static func statusString(phoneCaller: PhoneCaller) -> String {
        let flags = "hc" + (phoneCaller.hasChanges ? "1" : "0")
            + " sb" + (phoneCaller.shouldBlock ? "1" : "0")
            + " ib" + (phoneCaller.isBlocked ? "1" : "0")
            + " si" + (phoneCaller.shouldIdentify ? "1" : "0")
            + " ii" + (phoneCaller.isIdentified ? "1" : "0")
            + " sd" + (phoneCaller.shouldDelete ? "1" : "0")
        return flags
    }

    /// - Returns: a color representation of phoneCaller state
    static func statusColor(phoneCaller: PhoneCaller) -> UIColor {
        if phoneCaller.shouldDelete {
            return .lightGray
        }
        if phoneCaller.shouldBlock && phoneCaller.shouldIdentify {
            return .orange
        }
        if phoneCaller.shouldBlock {
            return UIColor.callKittyPaleRed()
        }
        if phoneCaller.shouldIdentify {
            return UIColor.callKittyPaleYellow()
        }
        if phoneCaller.hasChanges {
            return .green
        }
        return .white
    }

}
