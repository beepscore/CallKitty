# Purpose
Use CallKit to create a skeleton for a VoIP app.

# References

## Speakerbox: Using CallKit to create a VoIP app
Apple sample code
https://developer.apple.com/library/content/samplecode/Speakerbox/Introduction/Intro.html

## Call Directory Extension
Apps can create a Call Directory app extension to identify and block incoming callers by their phone number.  
https://developer.apple.com/documentation/callkit?preferredLanguage=occ

https://forums.developer.apple.com/thread/48837

## CallKit Tutorial for iOS
Hotline.app
note CallDirectoryHandler.swift is ~99% identical to Xcode Call Directory app extension template code.
https://www.raywenderlich.com/150015/callkit-tutorial-ios

## RealmSwiftExamples
https://github.com/beepscore/RealmSwiftExamples.git

## RealmService
Add a class similar to Realm: CRUD | Swift 4, Xcode 9
https://www.youtube.com/watch?v=hC6dLLbfUXc

# Results
CallKit requires an iPhone, doesn't work on simulator.

## CXProvider
App uses to report to system know about "out of band" notifications.
Not user actions but external events such as
    - an incoming call coming to the app
    - an outgoing call connected
    - a call ended on remote side

CXProvider uses CXCallUpdate to communicate to system.
System uses CXAction to communicate user actions to CXProvider.

In CallKitty, ProviderDelegate has a CXProvider.

## CXCallController
App uses to make requests to system. Handles local user actions such as
    - request to start a call
    - request to answer a call
    - request to end a call

CXCallController uses CXTransaction containing CXAction(s) to communicate to system.

In CallKitty, CallKittyCallManager has a CXCallController.

## incoming call flow
- network VOIP phone call comes to app
- app CXProvider sends CXCallUpdate to system
- system publishes event, others can observe including system Phone.app UI
- if user answers call, Phone.app UI sends answer action to system
- system sends CXAnswerCallAction to app CXProvider.
- app answers call on network

## end call flow
- in app UI, user requests to end call
- app CXCallController sends CXTransaction(CXEndCallAction) to system
- system checks request
- if system approves request, system sends CXEndCallAction back to app CXProvider

## CXCallDirectoryProvider
"The principal object for a Call Directory app extension for a host app."
In CallKitty, CallDirectoryHandler subclasses CXCallDirectoryProvider

### Call directory doesn't expose blocked list, app must maintain its own database
https://stackoverflow.com/questions/43125835/callkit-where-are-numbers-loaded-for-blocking-or-id-stored?rq=1

## How to use CallKittyDirectoryExtension
Shouldn't need to run scheme CallKittyDirectoryExtension first to update block and id lists, normal user is not going to do this.

Run scheme CallKitty on phone.

Settings app / Phone / Call Blocking & Identification / Allow these apps to block calls and provide caller id
Enable CallKitty

If app alerts allow microphone tap OK.

### CallDirectoryHandler
To hit breakpoints in CallDirectoryHandler, run scheme CallKittyDirectoryExtension and choose app CallKitty.
App may need to call reloadExtension.

###  beginRequest
Don't call it, let iOS call it?
https://stackoverflow.com/questions/43951781/callkit-extension-begin-request

CXCallDirectoryExtensionContext objects are not initialized directly, but are instead passed as arguments to the CXCallDirectoryProvider instance method beginRequest(with:).


### manually test blocked call
simulate incoming call from a blocked phone number e.g. 1_408_555_5555

### manually test caller id
simulate incoming call from an identified phone number e.g. 1_877_555_5555

## Appendix Sharing realm info between app and Call Directory extension

In this prototype I used a realm in a local file.
I think the Call Directory Extension realm can't see the CallKitty app realm database file.

To try to fix this, in the app I made an app group and used it to make a storage directory.
In target CallKitty / Capabilities / App Groups I added group.com.beepscore.CallKitty. (git commit f1cf015)

Then in RealmService I added configuration() to set file url and used it when instantiating a realm. (git commit 8aa5446)
However target CallKittyDirectoryExtension got nil when it attempted to use the file path.

Also Xcode build failed when I tried adding the app group to the extension.

In production, the app and/or the app extension could talk with an external realm platform server.
If both the app and the app extension talk with the same realm server, then they can access the same database.

### References
App extension programming guide / Handling common scenarios / Sharing data with your containing app
https://developer.apple.com/library/content/documentation/General/Conceptual/ExtensibilityPG/ExtensionScenarios.html
"Even though an app extension bundle is nested within its containing app’s bundle,
the running app extension and containing app have no direct access to each other’s containers.
You can, however, enable data sharing."

https://academy.realm.io/posts/tutorial-sharing-data-between-watchkit-and-your-app/
http://tackmobile.com/blog/App-Groups-and-iMessage-Extensions-for-iOS-10.html

## Appendix Record info about adding Realm framework for iOS to project.

### References

#### getting started
https://realm.io/docs/swift/latest/

#### realm-cocoa
https://github.com/realm/realm-cocoa

### Results

#### Approach 1: Git clone
I forked realm-cocoa, added branch beepscore, updated 2 projects to recommended settings.
Xcode says "conversion to Swift 4 is available". Every time I tap it Xcode crashes.

https://stackoverflow.com/questions/44640852/how-can-i-use-realm-with-swift-4/44641478#44641478

Also might need to clone recursive.

Try download framework instead.

#### Approach 2: download built framework
2017-11-06
got error module compiled with Swift 4.0 cannot be imported in Swift 4.0.2
https://stackoverflow.com/questions/47051318/realms-swift-module-compiled-with-swift-4-0-cannot-be-imported-in-swift-4-0-2

My Xcode is using Swift 4.0.2, not 4.0

    xcrun swift --version
    Apple Swift version 4.0.2 (swiftlang-900.0.69.2 clang-900.0.38)
    Target: x86_64-apple-macosx10.9

So need to compile from source.
Try Carthage.

#### Approach 3: Carthage

    brew install carthage

    carthage update

    *** Fetching realm-cocoa
    *** Downloading realm-cocoa.framework binary at "v3.0.1"
    *** Skipped installing realm-cocoa.framework binary due to the error:
        "Incompatible Swift version - framework was built with 4.0 (swiftlang-900.0.65 clang-900.0.37) and the local version is 4.0.2 (swiftlang-900.0.69.2 clang-900.0.38)."
    *** Checking out realm-cocoa at "v3.0.1"
    *** xcodebuild output can be found in /var/folders/g4/6bm303dn22n5tqj7jrdxrb5w0000gn/T/carthage-xcodebuild.QpIZ4e.log
    *** Building scheme "Realm" in Realm.xcworkspace
    *** Building scheme "RealmSwift" in Realm.xcworkspace

created Cartfile.resolved
