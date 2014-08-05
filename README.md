#iBeacon Storefront Greeter in Swift

You can find Xcode projects containing the customer and storefront applications shown in this tutorial's video [on my github][1].

This tutorial assumes the reader has basic knowledge of Apple's iBeacon protocol and its specifications. For an introductory tutorial to iBeacons, see the [Smart iBeacon][2] post.

Every morning on the way to work, I grab a latte from a coffee shop near my apartment. The baristas know me by name, and they know my usual order. It would be awesome if everywhere people shopped, they were treated as an individual instead of "just another customer". However, it is difficult for an employee (say, a barista) to remember the names of the hundreds of people they interact with on a daily basis.

Thus, we came up with a solution using Apple's iBeacon protocol and PubNub's data streaming network. In this tutorial, we will build a greeter application. Its primary functionality is to let a shopkeeper know when a customer enters the store and provide the shopkeeper with a little bit of information about the customer. This information allows the shopkeeper to personalize and improve the customer's experience.

##The Storefront Application

The intent of the storefront application is almost exclusively to display information. There isn't any required interaction between it and the shopkeeper. It merely assists the user with remembering the people they are intereacting with. The view consists of a table view and a status label at the bottom. The table view contains a list of customers currently in the store and a bit of information about them (in our case, their name, favorite drink, and a photo). 

<p align="center">
  <img src="https://github.com/ertheis/PubNubBeaconGreeter/blob/master/TutorialPics/StorefrontUI.png" alt="basic storefront UI" width="300">
</p>

Behind the scenes, the iDevice broadcasts an iBeacon unique to the shop (this could be done by independent beacon hardware). Meanwhile, the storefont app listens to a [PubNub DataSync Object][3] and a [PubNub Channel][4]. For now, we'll only worry about how communication looks from the storefront side. When a customer enters the shop, the DataSync object notifies us that something has changed and a message on the PubNub channel tells us what part of the object changed. We use this information to update the table and status label. We also highlight any new rows in the table for just over a second.
<p align="center">
  <img src="https://github.com/ertheis/PubNubBeaconGreeter/blob/master/TutorialPics/StorefrontNewCustomer.png" alt="basic storefront UI" width="300"> --> <img src="https://github.com/ertheis/PubNubBeaconGreeter/blob/master/TutorialPics/StorefrontNormal.png" alt="basic storefront UI" width="300">
</p>

[1]: http://www.github.com/ertheis/PubNubBeaconGreeter
[2]: https://github.com/ertheis/Smart-iBeacon/blob/master/README.md
[3]: http://www.pubnub.com/how-it-works/data-sync/
[4]: http://www.pubnub.com/how-it-works/data-streams/
