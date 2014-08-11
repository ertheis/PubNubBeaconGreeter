//
//  CustomerComm.swift
//  PubNubGreeterCustomer
//
//  Created by Eric Theis on 7/25/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

import Foundation

class CustomerComm: NSObject, PNDelegate {

    var pubKey = "pub-c-bf446f9e-dd7f-43fe-8736-d6e5dce3fe67"
    var subKey = "sub-c-d1c2cc5a-1102-11e4-8880-02ee2ddab7fe"
    var authKey = ""
    var sync_db = "CoffeeShop"
    
    var name = "Default Name"
    var favorite = "Default Drink"
    var pic = "./DefaultPic"
    var capturedPicData = NSData()
    
    var inShop = false
    var syncing = false
    
    var inside: BeaconNumbers
    var uuid: String = ""
    
    override init() {
        inside = BeaconNumbers(major: -1, minor: -1)
        super.init()
        PubNub.setDelegate(self)
        let myConfig = PNConfiguration(forOrigin: "pubsub-beta.pubnub.com", publishKey: self.pubKey, subscribeKey: self.subKey, secretKey: nil, authorizationKey: self.authKey)
        PubNub.setConfiguration(myConfig)
        PubNub.connect()
        uuid = PubNub.clientIdentifier()
    }
    
    func enterShop(major: Int, minor: Int) {
        if !inShop {
            PubNub.subscribeOnChannel(PNChannel.channelWithName("GreeterChannel96") as PNChannel) { (state: PNSubscriptionProcessState!, channels: [AnyObject]!, error: PNError!) in
                if !error {
                    PubNub.sendMessage(PubNub.clientIdentifier(), toChannel: PNChannel.channelWithName("GreeterChannel96") as PNChannel) { (state: PNMessageState!, data: AnyObject!) in
                        PubNub.unsubscribeFromChannel(PNChannel.channelWithName("GreeterChannel96") as PNChannel)
                    }
                } else {
                    println("BLOCK: \(error.code)")
                    println("BLOCK: \(error.description)")
                }
            }
            
            self.pic = self.capturedPicData.base64EncodedStringWithOptions(nil)
            if !syncing {
                PubNub.startObjectSynchronization("\(self.sync_db)\(major)\(minor)") { (syncObject: PNObject!, error: PNError!) in
                    if !error {
                        PubNub.updateObject("\(self.sync_db)\(major)\(minor)", withData: [self.uuid:["textLabel":"Name: \(self.name)", "detailTextLabel":"Favorite Drink: \(self.favorite)", "imgPath":self.pic]])
                        self.syncing = true
                    } else {
                        println("BLOCK: \(error.code)")
                        println("BLOCK: \(error.description)")
                    }
                }
            } else {
                PubNub.updateObject("\(self.sync_db)\(major)\(minor)", withData: [self.uuid:["textLabel":"Name: \(self.name)", "detailTextLabel":"Favorite Drink: \(self.favorite)", "imgPath":self.pic]])
            }
            inside = BeaconNumbers(major: major, minor: minor)
            inShop = true
        }
    }
    
    func leaveShop(major: Int, minor: Int) {
        if inShop {
            PubNub.deleteObject("\(self.sync_db)\(major)\(minor)", dataPath: self.uuid)
            inside = BeaconNumbers(major: -1, minor: -1)
            inShop = false
        }
    }
}

class BeaconNumbers: NSObject {
    var major: Int
    var minor: Int
    
    init(major: Int, minor: Int) {
        self.major = major
        self.minor = minor
        super.init()
    }
}