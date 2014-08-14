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
        status.text = "Scanning..."
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