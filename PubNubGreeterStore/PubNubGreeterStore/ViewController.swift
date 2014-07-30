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
    var defaultData: [NSDictionary] = [["textLabel":"Cutomers currently in the store will appear here.", "detailTextLabel":"iBeacon broadcast has started with Major: 9, Minor: 6.", "imgPath":"./DefaultPic"]]
    var tableData:PNObject = PNObject()
    
    let uuidObj = NSUUID(UUIDString: "0CF052C2-97CA-407C-84F8-B62AAC4E9020")
    
    var region = CLBeaconRegion()
    var beaconData = NSDictionary()
    var manager = CBPeripheralManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        self.region = CLBeaconRegion(proximityUUID: uuidObj, major: 9, minor: 6, identifier: "com.pubnub.test")
        self.beaconData = self.region.peripheralDataWithMeasuredPower(nil)
        self.manager = CBPeripheralManager(delegate: self, queue: nil)
        
        let myConfig = PNConfiguration(forOrigin: "pubsub-beta.pubnub.com", publishKey: appDelegate.pubKey, subscribeKey: appDelegate.subKey, secretKey: nil, authorizationKey: appDelegate.authKey)
        PubNub.setConfiguration(myConfig)
        PubNub.connect()
        PubNub.startObjectSynchronization(appDelegate.sync_db)
        
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
            self.tableView.reloadData()
        }
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        if(peripheral.state == CBPeripheralManagerState.PoweredOn) {
            println("powered on")
            self.manager.startAdvertising(beaconData)
        } else if(peripheral.state == CBPeripheralManagerState.PoweredOff) {
            println("powered off")
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
        if potentialCell? {
            cell = potentialCell!
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.textLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.textLabel.numberOfLines = 0
        
        var cellData: NSDictionary
        
        if tableData.count < 1 {
            cellData = defaultData[indexPath.row]
        } else {
            cellData = tableData.allValues[indexPath.row] as NSDictionary
        }
        
        cell.textLabel.text = cellData.objectForKey("textLabel") as String
        cell.detailTextLabel.text = cellData.objectForKey("detailTextLabel") as String
        var theImage = UIImage()
        if cellData.objectForKey("imgPath") as String == "./DefaultPic" {
            let path = NSBundle.mainBundle().pathForResource(cellData.objectForKey("imgPath") as String, ofType: "png")
            theImage = UIImage(contentsOfFile: path)
        } else {
            var raw = cellData.objectForKey("imgPath") as String
            theImage = UIImage(data: NSData(base64EncodedString: raw, options: NSDataBase64DecodingOptions.fromRaw(0)!))
        }
        cell.imageView.image = theImage
        return cell
    }
    
}

