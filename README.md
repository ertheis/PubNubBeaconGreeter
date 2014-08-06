#iBeacon Storefront Greeter
You can find Xcode projects containing the customer and storefront applications shown in this blog series's video [on my github][1].

This tutorial assumes the reader has basic knowledge of Apple's iBeacon protocol and its specifications. For an introductory tutorial to iBeacons, see the [Smart iBeacon][2] post.

Every morning on the way to work, I grab a latte from a coffee shop near my apartment. The baristas know me by name, and they know my usual order. It would be awesome if everywhere people shopped, they were treated as an individual instead of "just another customer". However, it is difficult for an employee (say, a barista) to remember the names of the hundreds of people they interact with on a daily basis.

We came up with a solution using Apple's iBeacon protocol and PubNub's data streaming network. In this tutorial, we will build a greeter application. Its primary functionality is to let a shopkeeper know when a customer enters the store and provide the shopkeeper with a little bit of information about the customer. This information allows the shopkeeper to personalize and improve the customer's experience.

##The Storefront Application
The intent of the storefront application is almost exclusively to display information. There isn't any required interaction between it and the shopkeeper. It merely assists the user with remembering the people they are intereacting with. The view consists of a table view and a status label at the bottom. The table view contains a list of customers currently in the store and a bit of information about them (in our case, their name, favorite drink, and a photo). 
<p align="center">
  <img src="https://github.com/ertheis/PubNubBeaconGreeter/blob/master/TutorialPics/StorefrontUI.png" alt="basic storefront UI" width="300">
</p>

Behind the scenes, the iDevice broadcasts an iBeacon unique to the shop (this could be done by independent beacon hardware). Meanwhile, the storefont app listens to a [PubNub DataSync Object][3] and a [PubNub Channel][4]. For now, we'll only worry about how communication looks from the storefront side. When a customer enters the shop, the DataSync object notifies us that something has changed and a message on the PubNub channel tells us what part of the object changed. We use this information to update the table and status label. We also highlight any new rows in the table for just over a second.
<p align="center">
  <img src="https://github.com/ertheis/PubNubBeaconGreeter/blob/master/TutorialPics/StorefrontNewCustomer.png" alt="basic storefront UI" width="300"> --> <img src="https://github.com/ertheis/PubNubBeaconGreeter/blob/master/TutorialPics/StorefrontNormal.png" alt="basic storefront UI" width="300">
</p>

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
Before we continue, make sure you've set up the PubNub iOS SDK as described [here][5]. These next properties are the default data for the table and the table data we will receive from PubNub. The data for our table view takes the form of a dictionary, which is the same type of information that can be stored in a PubNub DataSync object (a PNObject). Don't worry about the PNObject for now. What's important is that each row of the table uses information in a dictonary's textLabel, detailTextLabel, and imgPath keys.
```Swift
let defaultData = ["textLabel":"Cutomers currently in the store will appear here.", "detailTextLabel":"iBeacon broadcast has started with Major: 9, Minor: 6.", "imgPath":"./DefaultPic"]

var tableData:PNObject = PNObject()
```

Next, 
```Swift

```

[1]: http://www.github.com/ertheis/PubNubBeaconGreeter
[2]: https://github.com/ertheis/Smart-iBeacon/blob/master/README.md
[3]: http://www.pubnub.com/how-it-works/data-sync/
[4]: http://www.pubnub.com/how-it-works/data-streams/
[5]: http://www.pubnub.com/docs/objective-c/iOS/ios-sdk.html
