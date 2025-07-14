Everlink | Presence Verification

# Getting started with Everlink

### Guide focus:
Setting up Everlink’s iOS SDK to enable ultrasonic proximity verification.
This guide has been split into 2 parts:
Set Up
and
Usage.

### Prerequisites:
 Make sure that have the following:
- Xcode 11.0 or later
- CocoaPods 1.9.0 or later
- A project that targets iOS 12.0 or later.

## Set Up:
Please follow the steps below to get started:

> The Everlink SDK uses the microphone to record audio. ***Add
Privacy - Microphone Usage Description***
in the
***info.plist***
file for microphone access.


### Add EverLink SDK to your app
Create a Podfile if you don't already have one:

- In Terminal, navigate to the top-level folder of your project (the one with the xcodeproj file).

- Create a Podfile with the following command:

```swift
$ cd  your-project-directory
```

```swift
$ pod init
```

Add the Everlink SDK to your Podfile and install the Everlink SDK to your project as follows:

```swift
// Other codes...
target 'My Sample App' do
// Other codes...
pod 'EverlinkBroadcastSDK', '3.2.4'
end
```

```swift
$ pod install
```

After installing the pods, open your .xcworkspace file to see the project in Xcode:

```swift
$ open your-project.xcworkspace
```

From now onwards as your project contains a dependency managed by CocoaPods, you must use the
.xcworkspace file to open the project, not .xcodeproj.

## Usage:
After the client app is set up, you are ready to begin verifying and identifying devices,
you can now:
- 1) Generate user identifying tokens
- 2) Detect codes
- 3) Send codes

The EverLink class has a number of methods that you can use to send and receive audio codes. We do all
audiocode
generation, token checks and returns, and stop listening on code detection automatically.

### The code below demonstrates how to add Everlink to an existing ViewController.

Change all instances of ViewController example with the name of your View Controller, and let
**myAppID**
to your key, which you can find in the account page:

```swift
import UIKit
import EverlinkBroadcastSDK
class ViewController: UIViewController, EverlinkEventDelegate {
    var everlink:Everlink?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Other codes...
        let myAppID = "12345"
        everlink = Everlink(appID: myAppID)
        everlink?.delegate = self
        //set the output audio volume
        everlink?.playVolume(volume: 0.8, loudspeaker: true)
        // Other codes...
    }
    func onAudiocodeReceived(token: String) {
        // you can now identify, via the server returned token, what location/device was heard
        print(token)
    }
    func onMyTokenGenerated(token: String, oldToken: String) {
        //a new token generated, to save in your database
        print("New token: "+token)
        print("Old token: "+oldToken)
    }
}
```
##  1) Create token
If you wish to manually generate a new user token call:
createNewToken(startDate)

```swift
// Other codes...
@IBAction func newToken(_ sender: Any) {
    //Generate a new user token to save in your database
    do {
        try everlink?.createNewToken(startDate: "")
    } catch let error {
        print("Error caught: \(error)")
    }
}
// Other codes...
```
Function
**createNewToken**(startDate)
takes a validity start date in the form ‘YYYY-MM-DD’.
The token will be valid for 30 days after this date.
If no validity date is provided then it will be the current date. Once a device token is expired it will
automatically refresh.

We will return your identifying token via the
**onMyTokenGenerated**
delegate method.

```swift
func onMyTokenGenerated(token: String, oldToken: String) {
    //a new token generated, to save in your database
    sendEverlinkTokenToBackend(newToken)
}
```

This Everlink unique identifying token should be send to your backend and saved to your database and
associated with a
user. 

This will allow us to broadcast this users's identifier over ultrasound and allow other devices to
detect whether
they are in proximity with this user.

On your backend you might have some code like this:

```swift
“UPDATE employees SET everlink_token = newToken WHERE employee_id = ID”;
```

### Downloading Tokens
To download the audio code associated with a token so it can later be played or detected offline, call
function
**saveSounds()**
passing it an array of tokens:

```swift
// Other codes...
@IBAction func saveTokens(_ sender: Any) {
    //Save an array of tokens and their corresponding audio codes.
    let array = ["exampleToken12345", "exampleToken12346", "exampleToken12347"]
    everlink?.saveSounds(tokensArray: array)
}
// Other codes...
```

Call
**clearSounds()**
to delete all downloaded tokens and their corresponding audiocodes:

```swift
// Other codes...
@IBAction func clearTokens(_ sender: Any) {
    everlink?.clearSounds()
}
// Other codes...
```

## 2) Detect Code
When you want to detect an audiocode simply call:
**startDetecting()**

```swift
// Other codes...
@IBAction func startDetectingButton(_ sender: Any) {
    do {
        try everlink?.startDetecting()
    } catch {
        print("Error starting detecting: \(error)")
    }
}
@IBAction func stopDetectingButton(_ sender: Any) {
    everlink?.stopDetecting()
}
// Other codes...
```

Which will cause the device to start listening for an audiocode, on successful detection we will return
the
identifying
token of the heard device via the
**onAudioCodeReceived**
delegate method.

```swift
func onAudiocodeReceived(token: String) {
    sendEverlinkTokenToBackend(token)
}
```

You can now search your database using the returned Everlink unique identifying token to find the
detected
user. 

You might have some code like this on your backend:

```swift
"SELECT * FROM employees WHERE everlink_token = token";
```

## 3) Send Code
When you want to start emitting an audiocode simply call:
**startEmitting()**

```swift
// Other codes...
@IBAction func startPlayingButton(_ sender: Any) {
    everlink?.startEmitting() { error in
    if let error = error {
        print(error.getErrorMessage())
        print("Error starting emitting: \(error)")
    }
}
}
@IBAction func stopPlayingButton(_ sender: Any) {
everlink?.stopEmitting()
}
// Other codes...
```

You can alternatively pass a token as an argument:

```swift
// Other codes...
@IBAction func startPlayingButton(_ sender: Any) {
    everlink?.startEmittingToken(token: token) { error in
    if let error = error {
        print(error.getErrorMessage())
        print("Error starting emitting: \(error)")
    }
}
}
// Other codes...
```

Function
**playVolume**(volume, loudspeaker)
allows you to set the volume and whether the audio
should default
to the loudspeaker.

We can detect if headphones are in use, and route the audio to the device's loud speaker. Though users
might
experience
a short pause in any audio they are listening to, while the audiocode is played, before we automatically
resume playing
what they were listening to before the interruption.

---

To learn more, **[general documentation](https://developer.everlink.co/developer-documention/android)**,
**[error codes documentation](https://everlinkdev.github.io/everlink-error-handling/)**.