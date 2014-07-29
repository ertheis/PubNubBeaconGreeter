//
//  PNObjectSynchronizationEvent.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/13/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNDate;


#pragma mark - Types

typedef NS_OPTIONS(NSUInteger, PNObjectSynchronizationEventType) {

    /**
     Represent event which tell that initial object state arrived (there can be many events of this type for single
     object in case if whole packet can't be fitted in single response).
     */
    PNObjectInitEvent,

    /**
     Represent event because of which piece of object has been updated.
     */
    PNObjectUpdateEvent,

    /**
     Represent event because of which piece of object has been deleted.
     */
    PNObjectDeleteEvent,

    /**
     Represent event which mark that full set of information has been retrieved.
     */
    PNObjectCompleteEvent
};


#pragma mark - Public interface declaration

@interface PNObjectSynchronizationEvent : NSObject


#pragma mark - Properties

/**
 Stores reference on one of \b PNObjectSynchronizationEventType field values which represent type of event or it
 actual action which should be performed on local copy of object from \b PubNub cloud.
 */
@property (nonatomic, readonly, assign) PNObjectSynchronizationEventType type;

/**
 Stores reference on change transaction identifier (it will allow to filter target set of events).
 */
@property (nonatomic, readonly, copy) NSString *eventTransactionIdentifier;

/**
 Stores reference on remote object identifier for which this change has been generated.
 */
@property (nonatomic, readonly, copy) NSString *objectIdentifier;

/**
 Stores reference on location of the data which has been added/updated/deleted into/from object data tree.
 */
@property (nonatomic, readonly, copy) NSString *changeLocation;

/**
 Store reference on date when concrete change event has been triggered in cloud.
 */
@property (nonatomic, readonly, copy) NSString *changeDate;

/**
 Stores reference on actual value which should change existing value. In case if \c type is set to \b
 PNObjectDeleteEvent this value will be set to \c nil and will mean that information stored at \c changeLocation
 should be removed from object data tree.
 */
@property (nonatomic, readonly, strong) id changedData;

#pragma mark -


@end
