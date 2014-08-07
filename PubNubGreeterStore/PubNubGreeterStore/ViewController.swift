//
//  ViewController.swift
//  PubNubGreeter
//
//  Created by Eric Theis on 7/18/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

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
        
        let myConfig = PNConfiguration(forOrigin: "pubsub-beta.pubnub.com", publishKey: appDelegate.pubKey, subscribeKey: appDelegate.subKey, secretKey: nil, authorizationKey: appDelegate.authKey)
        PubNub.setConfiguration(myConfig)
        PubNub.connect()
        PubNub.startObjectSynchronization(appDelegate.sync_db)
        PubNub.subscribeOnChannel(PNChannel.channelWithName("GreeterChannel96") as PNChannel)
        
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
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if tableData.count > 0 {
            return tableData.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 80
    }
    
    func cellFormater(cell: UITableViewCell, highlighted: Bool) {
        if highlighted {
            cell.backgroundColor = UIColor(red: 206.0/255.0, green: 17/255.0, blue: 38/255.0, alpha: 1)
            cell.textLabel.textColor = UIColor.whiteColor()
            cell.detailTextLabel.textColor = UIColor.whiteColor()
            cell.imageView.layer.borderColor = UIColor(red: 206.0/255.0, green: 17/255.0, blue: 38/255.0, alpha: 1).CGColor
        } else {
            cell.backgroundColor = UIColor.whiteColor()
            cell.textLabel.textColor = UIColor.blackColor()
            cell.detailTextLabel.textColor = UIColor.blackColor()
            cell.imageView.layer.borderColor = UIColor.whiteColor().CGColor
        }
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var potentialCell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        var cell: UITableViewCell
        if potentialCell != nil {
            cell = potentialCell!
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }
        
        cellFormater(cell, highlighted: false)
        
        var cellData: Dictionary<String, String>
        if tableData.count < 1 {
            cellData = self.defaultData
        } else {
            cellData = tableData.allValues[indexPath.row] as Dictionary
            for var index = 0; index < changeData.count; index++ {
                if tableData.allKeys[indexPath.row] as String == changeData[index] {
                    cellFormater(cell, highlighted: true)
                    let delay = 1.5 * Double(NSEC_PER_SEC)
                    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                    dispatch_after(time, dispatch_get_main_queue()) {
                        self.cellFormater(cell, highlighted: false)
                    }
                    changeData.removeAtIndex(index)
                    break
                }
            }
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

