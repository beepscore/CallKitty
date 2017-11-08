/*
	Copyright (C) 2017 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Manager of CallKittyCalls, which demonstrates using a CallKit CXCallController to request actions on calls
*/

import UIKit
import CallKit

final class CallKittyCallManager: NSObject {

    let callController = CXCallController()

    // MARK: - Actions

    func startCall(handle: String, video: Bool = false) {
        let handle = CXHandle(type: .phoneNumber, value: handle)
        let startCallAction = CXStartCallAction(call: UUID(), handle: handle)

        startCallAction.isVideo = video

        let transaction = CXTransaction()
        transaction.addAction(startCallAction)

        requestTransaction(transaction)
    }

    func end(call: CallKittyCall) {
        let endCallAction = CXEndCallAction(call: call.uuid)
        let transaction = CXTransaction()
        transaction.addAction(endCallAction)

        requestTransaction(transaction)
    }

    func setHeld(call: CallKittyCall, onHold: Bool) {
        let setHeldCallAction = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
        let transaction = CXTransaction()
        transaction.addAction(setHeldCallAction)

        requestTransaction(transaction)
    }

    private func requestTransaction(_ transaction: CXTransaction) {
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("Requested transaction successfully")
            }
        }
    }

    // MARK: - Call Management

    static let CallsChangedNotification = Notification.Name("CallManagerCallsChangedNotification") 

    private(set) var calls = [CallKittyCall]()

    func callWithUUID(uuid: UUID) -> CallKittyCall? {
        guard let index = calls.index(where: { $0.uuid == uuid }) else {
            return nil
        }
        return calls[index]
    }

    func addCall(_ call: CallKittyCall) {
        calls.append(call)

        call.stateDidChange = { [weak self] in
            self?.postCallsChangedNotification()
        }

        postCallsChangedNotification()
    }

    func removeCall(_ call: CallKittyCall) {
        calls.removeFirst(where: { $0 === call })
        postCallsChangedNotification()
    }

    func removeAllCalls() {
        calls.removeAll()
        postCallsChangedNotification()
    }

    private func postCallsChangedNotification() {
        NotificationCenter.default.post(name: type(of: self).CallsChangedNotification, object: self)
    }

    // MARK: - CallKittyCallDelegate

    func speakerboxCallDidChangeState(_ call: CallKittyCall) {
        postCallsChangedNotification()
    }

}
