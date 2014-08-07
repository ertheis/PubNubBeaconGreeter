#iBeacon Storefront Greeter
You can find Xcode projects containing the customer and storefront applications shown in this blog series's video [on my github][1].

This tutorial assumes the reader has basic knowledge of Apple's iBeacon protocol and its specifications. For an introductory tutorial to iBeacons, see the [Smart iBeacon][2] post.

Every morning on the way to work, I grab a latte from a coffee shop near my apartment. The baristas know me by name, and they know my usual order. It would be awesome if everywhere people shopped, they were treated as an individual instead of "just another customer". However, it is difficult for an employee (say, a barista) to remember the names of the hundreds of people they interact with on a daily basis.

We came up with a solution using Apple's iBeacon protocol and PubNub's data streaming network. In this tutorial, we will build a greeter application. Its primary functionality is to let a shopkeeper know when a customer enters the store and provide the shopkeeper with a little bit of information about the customer. It's basically [our presence feature][3] in real life. This information allows the shopkeeper to personalize and improve the customer's experience.

In this blog post we'll make the storefront application. We'll allow the customer to create a profile. Then we'll learn how to load that profile into a PubNub DataSync database when we're in range of an iBeacon (The database we choose depends on information from the iBeacon). It is the second of two tutorials covering the creation of a storefront greeter system.

##The Customer Application: Publish a Profile With iBeacon
Our user profile will consist of three pieces of information: name, favorite drink, and a profile picture. Overall, our app will have two views. One will be for the user to input their information, and the other will display the user's profile and update them on the status of their iBeacon scans.

###Setup the iOS Storyboard

Start by embedding the default view in a navigation controller. Then we'll add two text fields (for the name and favorite drink) two buttons (one to initiate a camera view and the other to move to the next page), and a UIImageView (to display the captured picture). You can also add descriptive labels for each of the elements. Finally, create a new swift file (I named mine ProfileInput.swift) and set it as the controller for the view.

<p align="center">
  <img src="https://github.com/ertheis/PubNubBeaconGreeter/blob/master/TutorialPics/ProfileInputUI.png" alt="basic storefront UI" width="250">
</p

[1]: http://www.github.com/ertheis/PubNubBeaconGreeter
[2]: https://github.com/ertheis/Smart-iBeacon/blob/master/README.md
[3]: http://www.pubnub.com/how-it-works/presence/
