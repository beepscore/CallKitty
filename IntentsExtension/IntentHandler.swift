//
//  IntentHandler.swift
//  IntentsExtension
//
//  Created by Steve Baker on 11/7/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

/*
 Abstract:
 Intents handler principal class
 */

import Intents

class IntentHandler: INExtension, INStartAudioCallIntentHandling {

    func handle(intent: INStartAudioCallIntent, completion: @escaping (INStartAudioCallIntentResponse) -> Void) {
        let response: INStartAudioCallIntentResponse
        defer {
            completion(response)
        }

        // Ensure there is a person handle
        guard intent.contacts?.first?.personHandle != nil else {
            response = INStartAudioCallIntentResponse(code: .failure, userActivity: nil)
            return
        }

        let userActivity = NSUserActivity(activityType: String(describing: INStartAudioCallIntent.self))

        response = INStartAudioCallIntentResponse(code: .continueInApp, userActivity: userActivity)
    }

}
