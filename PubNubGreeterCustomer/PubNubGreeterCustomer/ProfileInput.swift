//
//  ProfileInput.swift
//  PubNubGreeterCustomer
//
//  Created by Eric Theis on 7/25/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

import UIKit
import MobileCoreServices

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
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}