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

# Results
CallKit requires an iPhone, doesn't work on simulator.

## How to use CallKittyDirectoryExtension
Might need to run scheme CallKittyDirectoryExtension first to update block and id lists, I'm not sure yet.

Run scheme CallKitty on phone.

Settings app / Phone / Call Blocking & Identification / Allow these apps to block calls and provide caller id
Enable CallKitty

If app alerts allow microphone tap OK.

### manually test blocked call
simulate incoming call from 1_408_555_5555

### manually test caller id
simulate incoming call from 1_877_555_5555
