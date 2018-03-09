# MeasureARKitPusher
Simple measure AR app made with ARKit. It sends the measures to Pusher so they can be consumed by other apps in realtime.

You can follow the [tutorial](https://pusher.com/tutorials/realtime-measuring-arkit/) to build this application or jump straight to the code.

[![Measuring app with ARKit and Pusher - 1](https://img.youtube.com/vi/osby8WfvPQA/0.jpg)](http://www.youtube.com/watch?v=osby8WfvPQA)

[![Measuring app with ARKit and Pusher - 2](https://img.youtube.com/vi/gRX3sHiV9Hg/0.jpg)](http://www.youtube.com/watch?v=gRX3sHiV9Hg)

The measurements are based on the plane detection’s capabilities of ARKit, and they are not perfect in some situations (for example, in low lighting or when a surface is not entirely flat) so the results won’t be completely accurate all the time, they’re close, but they can vary.

This app uses a beta version of the Pusher library for Swift 3.2 based on the branch https://github.com/pusher/pusher-websocket-swift/tree/swift-3.2. It will be updated when Pusher releases new version of the library to support Swift 4.


## Getting Started
1. Login to Pusher and [create an app](https://dashboard.pusher.com), with client events enabled (the option is in the _App Setting_ tab of the app).
2. Clone this repository and `cd` into it.
3. Open the workspace in Xcode 9.
4. Make sure the version of Swift is 3.2 in the PusherSwift target so it can compile without errors. In the project navigator, select Pods, then in the Targets section select PusherSwift, and in the Build Settings tab look for the option Swift Language Version. Change it to Swift 3.2 if necessary.
4. Edit `ViewController.swift` to enter you Pusher app key, secret, and cluster
5. You have to run the project in a real device with iOS 11. AR won’t work in the simulator, so configure a team to sign your app (a paid developer account is not required for testing in one device).
6. Wait until the app detect enough planes (the status will change to READY) to start measuring.
7. Go to the [Debug console](https://dashboard.pusher.com) to see the measuring events sent to Pusher.

### Prerequisites

- Xcode 9 (Beta 5 or superior)
- iOS 11 beta 5 (or superior)
- An iOS device with an A9 or better processor (iPhone 6s or superior, iPad Pro, iPad 2017)
- A free [Pusher](https://pusher.com) account

## Built With

* [Pusher](https://pusher.com/) - APIs to enable devs building realtime features
* [Xcode](https://developer.apple.com/xcode/) - Includes everything you need to create apps for iPhone, iPad, Mac, Apple Watch, and Apple TV.

## Acknowledgments

* Thanks to [Pusher](https://pusher.com/) for sponsoring this tutorial.

# License
MIT
