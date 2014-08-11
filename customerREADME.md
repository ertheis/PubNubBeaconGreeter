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

[1]: http://www.github.com/ertheis/PubNubBeaconGreeter
[2]: https://github.com/ertheis/Smart-iBeacon/blob/master/README.md
[3]: http://www.pubnub.com/how-it-works/presence/
