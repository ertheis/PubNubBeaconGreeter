#iBeacon Storefront Greeter
You can find Xcode projects containing the customer and storefront applications shown in this blog series's video [on my github][1].

This tutorial assumes the reader has basic knowledge of Apple's iBeacon protocol and its specifications. For an introductory tutorial to iBeacons, see the [Smart iBeacon][2] post.

Every morning on the way to work, I grab a latte from a coffee shop near my apartment. The baristas know me by name, and they know my usual order. It would be awesome if everywhere people shopped, they were treated as an individual instead of "just another customer". However, it is difficult for an employee (say, a barista) to remember the names of the hundreds of people they interact with on a daily basis.

We came up with a solution using Apple's iBeacon protocol and PubNub's data streaming network. In this tutorial, we will build a greeter application. Its primary functionality is to let a shopkeeper know when a customer enters the store and provide the shopkeeper with a little bit of information about the customer. It's basically [our presence feature][3] in real life. This information allows the shopkeeper to personalize and improve the customer's experience.

In this blog post we'll make the storefront application. We'll allow the customer to create a profile. Then we'll learn how to load that profile into a PubNub DataSync database when we're in range of an iBeacon (The database we choose depends on information from the iBeacon). It is the second of two tutorials covering the creation of a storefront greeter system.

##Create a Profile
Our user profile will consist of three pieces of information: name, favorite drink, and a profile picture. Overall, our app will have two views. One will be for the user to input their information, and the other will display the user's profile and update them on the status of their iBeacon scans.

###Setup the iOS Storyboard

Start by embedding the default view in a navigation controller. Then we'll add two text fields (for the name and favorite drink) two buttons (one to initiate a camera view and the other to move to the next page), and a UIImageView (to display the captured picture). You can also add descriptive labels for each of the elements. Finally, create a new swift file (I named mine ProfileInput.swift) and set it as the controller for the view.

<p align="center">
  <img src="https://github.com/ertheis/PubNubBeaconGreeter/blob/master/TutorialPics/ProfileInputUI.png" alt="basic storefront UI" width="250">
</p>

Remember to set your view controller to your new class (which should inherit from UIViewController) and hook up the name text field, favorite drink text field, and profile picture UIImageView to IBOutlets. Additionally, create IBAction functions for the take picture button and the two text fields. Note that our class also conforms to three delegate protocols. We'll use those later, so don't worry about any error messages related to the protocols for now. However, you can go ahead and set your text field's delegates to self in the viewDidLoad function.
```Swift
class ProfileInput: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var favoriteField: UITextField!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var profPic: UIImageView!
    
    override func viewDidLoad() {
        favoriteField.delegate = self
        nameField.delegate = self
        super.viewDidLoad()
    }
    
    @IBAction func takePicture(sender: UIButton) {
    }
    
    @IBAction func nameFilled(sender: UITextField) {
    }
    
    @IBAction func drinkFilled(sender: UITextField) {
    }
```

###Store the Profile Data
Before we continue, we'll want to create a place to store and manage the profile data. The class (and new swift file) we write will also manage our interaction with PubNub DataSync in future steps. I called mine CustomerComm. For now, Customer Comm can consist of 4 properties and an effectively empty init function. Create an object of this class in the AppDelegate (I named my object comm).
```Swift
class CustomerComm: NSObject, PNDelegate {
    var name = "Default Name"
    var favorite = "Default Drink"
    var pic = "./DefaultPic"
    var capturedPicData = NSData()
    
    override init(){
        super.init()
    }
}
```

Back in the ProfileInput view controller, we can access our CustomerComm object through the view controller. Thus, we can easily set the name and favorite variables to sync with text entered into their corresponding text fields. Our ProfileInput class should now look like this:
```Swift
class ProfileInput: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    @IBOutlet var favoriteField: UITextField!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var profPic: UIImageView!
    
    override func viewDidLoad() {
        favoriteField.delegate = self
        nameField.delegate = self
        super.viewDidLoad()
    }
    
    @IBAction func takePicture(sender: UIButton) {
        if !startCameraController() {
            println("The camera is not accessible.")
        }
    }
    
    @IBAction func nameFilled(sender: UITextField) {
        appDelegate.comm.name = sender.text
    }
    
    @IBAction func drinkFilled(sender: UITextField) {
        appDelegate.comm.favorite = sender.text
    }
```

###Capture a Profile Picture
Let's write the startCameraController function you might have noticed above. You also might have guessed that it has a boolean return value. First we ensure the camera is available (if it's not, return false). Then we create a UIImagePickerController and set its source type, media type to values that only allow a picture. We enable editing because by default this will make the user crop the photo into a square. We set the delegate to self and trigger the view to launch before returning true.
```Swift
    func startCameraController() -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == false {
            return false
        }
        
        var cameraUI = UIImagePickerController()
        cameraUI.sourceType = UIImagePickerControllerSourceType.Camera
        cameraUI.mediaTypes = [kUTTypeImage as AnyObject]
        cameraUI.allowsEditing = true
        cameraUI.delegate = self
        self.presentViewController(cameraUI, animated: true, completion: nil)
        return true
    }
```

Now, we'll write two delegate functions that conform to the UIImagePickerControllerDelegate. The first basically takes us back to the profile input view if the user hits cancel. THe next actually deals with an image the user takes. First, we compress the image to around 20kb (small enough to fit in a PubNub message). We'll write that function next. We then take the compressed image and display it on our UIImageView as it will appear to the store: cropped into a circle. Finally, we return to our profile input view by dismissing our imagePicker view. Note that throughout this entire process, we store data in our comm object, not in our view controller.
```Swift
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        appDelegate.comm.capturedPicData = compressImage(image)
        profPic.image = UIImage(data: appDelegate.comm.capturedPicData)
        profPic.layer.cornerRadius = 100
        profPic.layer.borderWidth = 1
        profPic.layer.masksToBounds = true
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
```

The compressImage function is basically a loop that compressing the original image by an increasing factor until it is smaller than the required size (20kb or 20*1024 bytes).
```Swift
    func compressImage(image: UIImage) -> NSData {
        var compression: CGFloat = 0.9
        var raw: NSData = UIImageJPEGRepresentation(image, compression)
        while raw.length > (20*1024) {
            if compression > 0.1 {
                compression -= 0.1
            } else {
                compression -= 0.01
            }
            raw = UIImageJPEGRepresentation(image, compression)
        }
        return raw
    }
```

The last thing we do is allow the user to dismiss the keyboard when they hit enter. Otherwise, if the user tries to edit their name after taking their picture, the keyboard will block the continue button.
```Swit
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
```

##The iBeacon Trigger
Now we get to the interesting part. In this section we'll set up iBeacon detection and use it to trigger updates for our store side app. In this tutorial, I set the "enter shop" trigger at "immediate" range and the "leave shop" trigger at "far" for easy testing.

###Back to the Communication Class
Because we decided to store all data in the communication class, we'll build here first. We'll also put the functions that are triggered by the iBeacon here. Start by creating a class called BeaconNumbers (in the same file as your "CustomerComm" class) as well as a property containing an object of it. You can instantiate it in the init function. This data structure will allow us to leave a shop when we don't necessarily have access to a ranged beacon.
```Swift
class CustomerComm: NSObject, PNDelegate {
    var name = "Default Name"
    var favorite = "Default Drink"
    var pic = "./DefaultPic"
    var capturedPicData = NSData()
    
    var inside: BeaconNumbers
    
    override init(){
        inside = BeaconNumbers(major: -1, minor: -1)
        super.init()
    }
}

class BeaconNumbers: NSObject {
    var major: Int
    var minor: Int
    
    init(major: Int, minor: Int) {
        self.major = major
        self.minor = minor
        super.init()
    }
}
```

As stated above, we also want to make enter and exit functions (for now, we'll leave them empty).
```Swift
class CustomerComm: NSObject, PNDelegate {
    //insert properties here
    
    override init(){
        inside = BeaconNumbers(major: -1, minor: -1)
        super.init()
    }
    
    func enterShop(major: Int, minor: Int) {
    }
    
    func leaveShop(major: Int, minor: Int) {
    }
}

//BeaconNumbers class
```

###Detect an iBeacon
Now that we've made the layer with which our next view controller will interface, go ahead and create a new view controller and set the "next" button from the profile input view to load it. In the demo code, I just called it ViewController. For the demo's purposes, I included labels for the name, favorite drink, and status in addition to a UIImageView to display the profile pic.

<p align="center">
  <img src="https://github.com/ertheis/PubNubBeaconGreeter/blob/master/TutorialPics/ViewControllerStoryboard.png" alt="basic storefront UI" width="250">
</p>

The code for this class simply formats the view and sets up the iBeacon detection. When we're in range of an iBeacon, we range it and decide at what distances we want our user to "enter shop" and "leave shop". If you know how iBeacons work, go ahead and skim/implement this and move on to the next section. The one point of note is that when we leave a region, we can just use the BeaconNumbers object to retreive the major and minor numbers of the beacon we just lost.

For those of you who didn't read the first tutorial on iBeacons (shame!), I'll give a closer overview of what I did. I start by retreiving the data for my labels and creating a region associated with the UUID we used in the store app. This allows us to view beacons emitting that UUID. We then use delegate functions to notify ourselves when we've found or lost a beacon and detect the range of beacons we've found. Once we've ranged a beacon (which means that in addition to seeing a beacon, we've determined how far/close it is) we can decide based on its distance whether we should be calling the enterShop or leaveShop functions attached to our comm object. All along the way, I'm updating the status label so our tester can see the iBeacon state.
```Swift
//
//  ViewController.swift
//  PubNubGreeterCustomer
//
//  Created by Eric Theis on 7/25/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var favoriteLabel: UILabel!
    @IBOutlet var profPic: UIImageView!
    @IBOutlet var status: UILabel!
    
    let uuidObj = NSUUID(UUIDString: "0CF052C2-97CA-407C-84F8-B62AAC4E9020")
    
    var region = CLBeaconRegion()
    var manager = CLLocationManager()
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = "Name: \(appDelegate.comm.name)"
        favoriteLabel.text = "Favorite Drink: \(appDelegate.comm.favorite)"
        profPic.image = UIImage(data: appDelegate.comm.capturedPicData)
        profPic.layer.cornerRadius = 100
        profPic.layer.borderWidth = 1
        profPic.layer.masksToBounds = true
        manager.delegate = self
        region = CLBeaconRegion(proximityUUID: uuidObj, identifier: "com.pubnub.test")
        var os = UIDevice.currentDevice().systemVersion
        if(os.substringToIndex(os.startIndex.successor()).toInt() >= 8){
            self.manager.requestAlwaysAuthorization()
        }
        self.manager.startMonitoringForRegion(self.region)
    }
    
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        println("Scanning...")
        manager.startRangingBeaconsInRegion(region as CLBeaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        println(error)
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        manager.startRangingBeaconsInRegion(region as CLBeaconRegion)
        println("Possible Match")
        status.text = "Possible Match"
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        self.appDelegate.comm.leaveShop(self.appDelegate.comm.inside.major, minor: self.appDelegate.comm.inside.minor)
        status.text = "Left the Shop"
        manager.stopRangingBeaconsInRegion(region as CLBeaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: NSArray!, inRegion region: CLBeaconRegion!) {
        if(beacons.count == 0) { return }
        
        for beaconIndex in 0...beacons.count-1 {
            var beacon = beacons[beaconIndex] as CLBeacon
            
            if (beacon.proximity == CLProximity.Unknown) {
                println("Unknown Proximity")
                status.text = "Unknown Proximity"
                appDelegate.comm.leaveShop(beacon.major, minor: beacon.minor)
            } else if (beacon.proximity == CLProximity.Immediate) {
                println("Immediate")
                status.text = "Immediate"
                appDelegate.comm.enterShop(beacon.major, minor: beacon.minor)
            } else if (beacon.proximity == CLProximity.Near) {
                println("Near")
                status.text = "Near"
                appDelegate.comm.leaveShop(beacon.major, minor: beacon.minor)
            } else if (beacon.proximity == CLProximity.Far) {
                println("Far")
                status.text = "Far"
                appDelegate.comm.leaveShop(beacon.major, minor: beacon.minor)
            }
        }
    }
}
```

##Implement PubNub DataSync and DataStream
Now that we have the iBeacon triggering our enterShop and leaveShop functions, we can use those functions to give or take our information from the storefront app. Recall that our storefront app is syncing with the DataSync object and PNChannel containing its iBeacon's major and minor identification numbers. Thus, when we are in rage of an iBeacon, we can use those numbers to decide where to publish data.

[1]: http://www.github.com/ertheis/PubNubBeaconGreeter
[2]: https://github.com/ertheis/Smart-iBeacon/blob/master/README.md
[3]: http://www.pubnub.com/how-it-works/presence/
