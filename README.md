#iBeacon Storefront Greeter
You can find Xcode projects containing the customer and storefront applications shown in this blog series's video [on my github][1].

This tutorial assumes the reader has basic knowledge of Apple's iBeacon protocol and its specifications. For an introductory tutorial to iBeacons, see the [Smart iBeacon][2] post.

Every morning on the way to work, I grab a latte from a coffee shop near my apartment. The baristas know me by name, and they know my usual order. It would be awesome if everywhere people shopped, they were treated as an individual instead of "just another customer". However, it is difficult for an employee (say, a barista) to remember the names of the hundreds of people they interact with on a daily basis.

We came up with a solution using Apple's iBeacon protocol and PubNub's data streaming network. In this tutorial, we will build a greeter application. Its primary functionality is to let a shopkeeper know when a customer enters the store and provide the shopkeeper with a little bit of information about the customer. This information allows the shopkeeper to personalize and improve the customer's experience.

##The Storefront Application: the UI and iBeacon Broadcast
The intent of the storefront application is almost exclusively to display information. There isn't any required interaction between it and the shopkeeper. It merely assists the user with remembering the people they are intereacting with. The view consists of a table view and a status label at the bottom. The table view contains a list of customers currently in the store and a bit of information about them (in our case, their name, favorite drink, and a photo). 
<p align="center">
  <img src="https://github.com/ertheis/PubNubBeaconGreeter/blob/master/TutorialPics/StorefrontUI.png" alt="basic storefront UI" width="300">
</p>

Behind the scenes, the iDevice broadcasts an iBeacon unique to the shop (this could be done by independent beacon hardware). Meanwhile, the storefont app listens to a [PubNub DataSync Object][3] and a [PubNub Channel][4]. For now, we'll only worry about how communication looks from the storefront side. When a customer enters the shop, the DataSync object notifies us that something has changed and a message on the PubNub channel tells us what part of the object changed. We use this information to update the table and status label. We also highlight any new rows in the table for just over a second.
<p align="center">
  <img src="https://github.com/ertheis/PubNubBeaconGreeter/blob/master/TutorialPics/StorefrontNewCustomer.png" alt="basic storefront UI" width="300"> --> <img src="https://github.com/ertheis/PubNubBeaconGreeter/blob/master/TutorialPics/StorefrontNormal.png" alt="basic storefront UI" width="300">
</p>

This blog post will cover the creation of the user interface, the logic required to load a set of user profile, and the broadcast of an iBeacon. It is the first in a series of four tutorials covering the creation of a storefront greeter system.

###Setup the User Interface

We'll start by creating the user interface and linking it to our view controller. After you create a new single view Xcode project, go to the storyboard and drag a table view onto the default view controller. Leave a little space at the bottom and place a label as well. Everything should look approximately like the picture below:
<p align="center">
  <img src="https://github.com/ertheis/PubNubBeaconGreeter/blob/master/TutorialPics/ViewSetup.png" alt="basic storefront UI" width="500">
</p>
Now, go to the view controller and set it to conform to the UITableViewDataSource and UITableViewDelegate protocols. Additionally, create two properties: One for the status label and one for the table view.

```Swift
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var status: UILabel!
    
}
```
Now, go ahead and set the dataSource and delegate of the table view to your view controller. Also hook up the referencing outlets for the table view and label to the properties you created in your view controller. You'll probably get some errors related to conforming to protocols. You can get rid of these by adding the functions below (we'll fill them out in the next section).

```Swift
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
      return 0
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
      return 0
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
      return nil
    }
```

###Just Add Data
Before we continue, make sure you've [set up the PubNub iOS SDK][5]. These next properties are the default data for the table and the table data we will receive from PubNub. The data for our table view takes the form of a dictionary, which is the same type of information that can be stored in a PubNub DataSync object (a PNObject). Don't worry about the PNObject for now. What's important is that each row of the table uses information in a dictonary's textLabel, detailTextLabel, and imgPath keys. For the non-default case, the textLabel is a customer's name, detailTextLabel is their favorite drink, and imgPath is a base_64 encoded string containing a compressed image.
```Swift
let defaultData = ["textLabel":"Cutomers currently in the store will appear here.", "detailTextLabel":"iBeacon broadcast has started with Major: 9, Minor: 6.", "imgPath":"./DefaultPic"]

var tableData:PNObject = PNObject()
```

Next, we'll set the return values for the numberOfRowsInSection and hightForRowAtIndexPath functions. We haven't placed any information in tableData yet, so it will always return 1 for now. The return value of heightForRowAtIndexPath is the height of each row of the table in pixels. I found that 80 works well.
```Swift
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if tableData.count > 0 {
            return tableData.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 80
    }
```

The cellForRowAtIndexPath function fills out each row of the table with the information in the tableData dictionary (or the one row with the default data if our tableData is empty). We start by dequeue-ing a useable cell with a subtitle style or creating one if it doesn't exist. We then disable cell selection, allow text lines to wrap, set the number of lines to scale with the content, and add a white border to create separation between the images. We then grab the data specific to this row from tableData or defaultData if tableData is empty. Finally, we fill each component of the cell with its data. In the case of the image, the default image is stored with the app while a profile picture is base_64 encoded.
```Swift
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var potentialCell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        var cell: UITableViewCell
        if potentialCell != nil {
            cell = potentialCell!
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }
        
        //Formatting to make things look pretty. numberOfLines = 0 means that it will automatically
        //adjust to fit the content.
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.textLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.textLabel.numberOfLines = 0
        
        //add a white boarder to create spacing between images
        cell.imageView.layer.borderColor = UIColor.whiteColor().CGColor
        cell.imageView.layer.cornerRadius = 40
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.masksToBounds = true
        
        var cellData: Dictionary<String, String>
        if tableData.count < 1 {
            cellData = self.defaultData
        } else {
            cellData = tableData.allValues[indexPath.row] as Dictionary
        }
        
        cell.textLabel.text = cellData["textLabel"]
        cell.detailTextLabel.text = cellData["detailTextLabel"]
        var theImage = UIImage()
        if cellData["imgPath"] == "./DefaultPic" {
            let path = NSBundle.mainBundle().pathForResource(cellData["imgPath"], ofType: "png")
            theImage = UIImage(contentsOfFile: path)
        } else {
            var raw = cellData["imgPath"] as String?
            theImage = UIImage(data: NSData(base64EncodedString: raw!, options: NSDataBase64DecodingOptions.fromRaw(0)!))
        }
        cell.imageView.image = theImage
        return cell
    }
}
```

Now, you should have an application that is ready to receive and display data in a table view. Next we'll add iBeacon broadcasting. 

###Broadcast an iBeacon
Modify the viewDidLoad function to include the additional lines of code below. You'll also want to add imports for CoreLocation and CoreBluetooth at the top of your file. We're assuming that you know the basics of the iBeacon protocol and its specifications. If you don't there's a good intro in my [Smart iBeacon][6] blog post. We're basically defining the information our beacon will broadcast and signaling the core blutooth peripheral manager to begin monitoring our bluetooth hardware's status.
```Swift
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uuidObj = NSUUID(UUIDString: "0CF052C2-97CA-407C-84F8-B62AAC4E9020")
        self.region = CLBeaconRegion(proximityUUID: uuidObj, major: 9, minor: 6, identifier: "com.pubnub.test")
        beaconData = self.region.peripheralDataWithMeasuredPower(nil) as NSDictionary
        self.manager = CBPeripheralManager(delegate: self, queue: nil)
    }
```

Next, we define the function peripheralManagerDidUpdateState. This function broadcasts our iBeacon when bluetooth is on and stops attempting to broadcast when its off. Additionally, it sets the status label accordingly. We store the state of the status label in a string for when we breifly display text later in this tutorial.
```Swift
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        if(peripheral.state == CBPeripheralManagerState.PoweredOn) {
            println("powered on")
            self.beaconText = "Beacon Advertising"
            self.status.text = self.beaconText
            self.manager.startAdvertising(beaconData)
        } else if(peripheral.state == CBPeripheralManagerState.PoweredOff) {
            println("powered off")
            self.beaconText = "Beacon Off"
            self.status.text = self.beaconText
            self.manager.stopAdvertising()
        }
    }
```

Your ViewController class should now look something like this:
```Swift
import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBPeripheralManagerDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var status: UILabel!
    var beaconText = "Loading..."
    
    let defaultData = ["textLabel":"Cutomers currently in the store will appear here.", "detailTextLabel":"iBeacon broadcast has started with Major: 9, Minor: 6.", "imgPath":"./DefaultPic"]
    var tableData:PNObject = PNObject()
    var changeData:[String] = []
    
    var region = CLBeaconRegion()
    var beaconData = NSDictionary()
    var manager = CBPeripheralManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let uuidObj = NSUUID(UUIDString: "0CF052C2-97CA-407C-84F8-B62AAC4E9020")
        self.region = CLBeaconRegion(proximityUUID: uuidObj, major: 9, minor: 6, identifier: "com.pubnub.test")
        beaconData = self.region.peripheralDataWithMeasuredPower(nil) as NSDictionary
        self.manager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        if(peripheral.state == CBPeripheralManagerState.PoweredOn) {
            println("powered on")
            self.beaconText = "Beacon Advertising"
            self.status.text = self.beaconText
            self.manager.startAdvertising(beaconData)
        } else if(peripheral.state == CBPeripheralManagerState.PoweredOff) {
            println("powered off")
            self.beaconText = "Beacon Off"
            self.status.text = self.beaconText
            self.manager.stopAdvertising()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if tableData.count > 0 {
            return tableData.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var potentialCell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        var cell: UITableViewCell
        if potentialCell != nil {
            cell = potentialCell!
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.textLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.textLabel.numberOfLines = 0
        cell.imageView.layer.borderColor = UIColor.whiteColor().CGColor
        
        var cellData: Dictionary<String, String>
        if tableData.count < 1 {
            cellData = self.defaultData
        } else {
            cellData = tableData.allValues[indexPath.row] as Dictionary
        }
        
        cell.textLabel.text = cellData["textLabel"]
        cell.detailTextLabel.text = cellData["detailTextLabel"]
        var theImage = UIImage()
        if cellData["imgPath"] == "./DefaultPic" {
            let path = NSBundle.mainBundle().pathForResource(cellData["imgPath"], ofType: "png")
            theImage = UIImage(contentsOfFile: path)
        } else {
            var raw = cellData["imgPath"] as String?
            theImage = UIImage(data: NSData(base64EncodedString: raw!, options: NSDataBase64DecodingOptions.fromRaw(0)!))
        }
        cell.imageView.image = theImage
        cell.imageView.layer.cornerRadius = 40
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.masksToBounds = true
        return cell
    }
    
}
```

That's it for the setup; you're now able to populate cells of a table view and broadcast an iBeacon from your iDevice. Stay tuned for part two of the series.

##The Storefront Application: Fetching User Profiles

This is part 2 of 4 of the tutorials covering a storefront greeter application. In this post, I'll show you how to sync your UI with an updating dictionary of customers in your shop. Additionally, you'll breifly notify users of new customers.

###Connecting to PubNub
As mentioned in the previous post, you should have already loaded the [PubNub iOS SDK][5] into your project. We'll begin by setting up the connection to PubNub. If you're following on the Xcode project, I defined my keys in the AppDelegate class so that I can access them if using PubNub in other parts of my application.  Define a PNConfiguration and set the configuration before connecting. After you connect, begin synchronization with a database who's name contains the major and minor identification numbers you are broadcasting with your iBeacon. Subscribe to a channel named similarly.
```Swift
    override func viewDidLoad() {
        super.viewDidLoad()
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let uuidObj = NSUUID(UUIDString: "0CF052C2-97CA-407C-84F8-B62AAC4E9020")
        self.region = CLBeaconRegion(proximityUUID: uuidObj, major: 9, minor: 6, identifier: "com.pubnub.test")
        beaconData = self.region.peripheralDataWithMeasuredPower(nil) as NSDictionary
        self.manager = CBPeripheralManager(delegate: self, queue: nil)
        
        let myConfig = PNConfiguration(forOrigin: "pubsub-beta.pubnub.com", publishKey: "your publish key", subscribeKey: "your subscribe key", secretKey: nil, authorizationKey: nil)
        PubNub.setConfiguration(myConfig)
        PubNub.connect()
        PubNub.startObjectSynchronization("CoffeeShop96")
        PubNub.subscribeOnChannel(PNChannel.channelWithName("GreeterChannel96") as PNChannel)
    }
```

In the same function, viewDidLoad, add three PubNub observers: ObjectSynchronizationStart, ObjectChange, and MessageReceive. The first makes the initial copy of the object. The second updates the object whenever a change is detected and also temporarily changes the status label to "Presence Change". The third appends any messages received on the change data channel to the end of an array. The messages contain the keys of the branches that have been added to the object.

Whenever an object change occurs (and on the initial copy of the object) we instruct the table view to reload. This allows us to update the content of its cells.
```Swift
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup iBeacon and Connnect to PubNub here
        
        PNObservationCenter.defaultCenter().addObjectSynchronizationStartObserver(self) { (syncObject: PNObject!, error: PNError!) in
            if !error {
                self.tableData = syncObject
                self.tableView.reloadData()
            } else {
                println("OBSERVER: \(error.code)")
                println("OBSERVER: \(error.description)")
            }
        }
        
        PNObservationCenter.defaultCenter().addObjectChangeObserver(self) { (syncObject: PNObject!) in
            self.tableData = syncObject
            self.status.text = "Presence Change"
            let delay = 1 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {self.status.text = self.beaconText})
            self.tableView.reloadData()
        }
        
        PNObservationCenter.defaultCenter().addMessageReceiveObserver(self) { (message: PNMessage!) in
            self.changeData.append(message.message as String)
        }
    }
```

###Highlighting Changes
Because of the way we set up our table view in the last post, it will automatically switch its data source to our DataSync object when it has at least one element in it (when there is at least one person in the store). However, we also want to temporarily highlight any new customers in the table. We do this in the cellForRowAtIndexPath function. Recall that we receive the keys of new rows over the channel we subscribed on. Thus, we can iterate through the array of keys and temporarily change them red. Once we have signaled the cell to turn red for 1.5 seconds, we remove its key from the array. Note that when we turn the row red, we also turn the boarder of the profile image red to match and the row's text white for readability. To delay the row's return to its original colors, we use the dispatch_after function.
```Swift
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var potentialCell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        var cell: UITableViewCell
        if potentialCell != nil {
            cell = potentialCell!
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.textLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.textLabel.numberOfLines = 0
        cell.imageView.layer.borderColor = UIColor.whiteColor().CGColor
        
        var cellData: Dictionary<String, String>
        if tableData.count < 1 {
            cellData = self.defaultData
        } else {
            cellData = tableData.allValues[indexPath.row] as Dictionary
            //START OF NEW CODE
            if !changeData.isEmpty {
                for index in 0...changeData.count-1 {
                    if tableData.allKeys[indexPath.row] as String == changeData[index] {
                        cell.backgroundColor = UIColor(red: 206.0/255.0, green: 17/255.0, blue: 38/255.0, alpha: 1)
                        cell.textLabel.textColor = UIColor.whiteColor()
                        cell.detailTextLabel.textColor = UIColor.whiteColor()
                        cell.imageView.layer.borderColor = UIColor(red: 206.0/255.0, green: 17/255.0, blue: 38/255.0, alpha: 1).CGColor
                        let delay = 1.5 * Double(NSEC_PER_SEC)
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                        dispatch_after(time, dispatch_get_main_queue()) {
                            cell.backgroundColor = UIColor.whiteColor()
                            cell.textLabel.textColor = UIColor.blackColor()
                            cell.detailTextLabel.textColor = UIColor.blackColor()
                            cell.imageView.layer.borderColor = UIColor.whiteColor().CGColor
                        }
                        changeData.removeAtIndex(index)
                        break
                    }
                }
            }
            //END OF NEW CODE
        }
        
        cell.textLabel.text = cellData["textLabel"]
        cell.detailTextLabel.text = cellData["detailTextLabel"]
        var theImage = UIImage()
        if cellData["imgPath"] == "./DefaultPic" {
            let path = NSBundle.mainBundle().pathForResource(cellData["imgPath"], ofType: "png")
            theImage = UIImage(contentsOfFile: path)
        } else {
            var raw = cellData["imgPath"] as String?
            theImage = UIImage(data: NSData(base64EncodedString: raw!, options: NSDataBase64DecodingOptions.fromRaw(0)!))
        }
        cell.imageView.image = theImage
        cell.imageView.layer.cornerRadius = 40
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.masksToBounds = true
        return cell
    }
```

[1]: http://www.github.com/ertheis/PubNubBeaconGreeter
[2]: https://github.com/ertheis/Smart-iBeacon/blob/master/README.md
[3]: http://www.pubnub.com/how-it-works/data-sync/
[4]: http://www.pubnub.com/how-it-works/data-streams/
[5]: http://www.pubnub.com/docs/objective-c/iOS/ios-sdk.html
[6]: insertSmartIBeaconPost
