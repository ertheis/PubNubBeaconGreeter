//
//  CustomerComm.swift
//  PubNubGreeterCustomer
//
//  Created by Eric Theis on 7/25/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

import Foundation

class CustomerComm: NSObject, PNDelegate {

    let pubKey = "pub-c-bf446f9e-dd7f-43fe-8736-d6e5dce3fe67"
    let subKey = "sub-c-d1c2cc5a-1102-11e4-8880-02ee2ddab7fe"
    var authKey = ""
    let sync_db = "CoffeeShop"
    let sync_channel = "GreeterChannel"
    
    var name = "Default Name"
    var favorite = "Default Drink"
    var pic = "./DefaultPic"
    var capturedPicData = NSData()
    
    var inShop = false
    
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
    
    func notifyChange(major: Int, minor: Int) {
        PubNub.sendMessage(PubNub.clientIdentifier(), toChannel: PNChannel.channelWithName("\(self.sync_channel)\(major)\(minor)") as PNChannel)
    }
    
    func sendData(major: Int, minor: Int) {
        self.pic = self.capturedPicData.base64EncodedStringWithOptions(nil)
        PubNub.updateObject("\(self.sync_db)\(major)\(minor)", withData: [self.uuid:["textLabel":"Name: \(self.name)", "detailTextLabel":"Favorite Drink: \(self.favorite)", "imgPath":self.pic]])
    }
    
    func enterShop(major: Int, minor: Int) {
        if !inShop {
            inShop = true
            inside = BeaconNumbers(major: major, minor: minor)
            notifyChange(major, minor: minor)
            sendData(major, minor: minor)
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