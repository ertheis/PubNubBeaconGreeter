//
//  ProfileInput.swift
//  PubNubGreeterCustomer
//
//  Created by Eric Theis on 7/25/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

import UIKit

class ProfileInput: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //startCameraController()
    }
    
    func startCameraController() -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == false {
            return false
        }
        
        var cameraUI = UIImagePickerController()
        cameraUI.sourceType = UIImagePickerControllerSourceType.Camera
        cameraUI.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.Camera)
        cameraUI.allowsEditing = false
        
        cameraUI.delegate = self
        self.presentViewController(cameraUI, animated: true, completion: nil)
        return true
    }
    
    @IBAction func nameFilled(sender: UITextField) {
        appDelegate.comm.name = sender.text
    }
    
    @IBAction func drinkFilled(sender: UITextField) {
        appDelegate.comm.favorite = sender.text
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        picker.parentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!) {
        var type = info.objectForKey(UIImagePickerControllerMediaType) as String
        var originalImage: UIImage, editedImage: UIImage?, imageToSave: UIImage
        
        editedImage = info.objectForKey(UIImagePickerControllerEditedImage) as? UIImage
        originalImage = info.objectForKey(UIImagePickerControllerOriginalImage) as UIImage
        
        if editedImage? {
            imageToSave = editedImage!
        } else {
            imageToSave = originalImage
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}