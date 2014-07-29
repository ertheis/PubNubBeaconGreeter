//
//  PNObjectModificationInformation.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//


#pragma mark - Types

typedef NS_OPTIONS(NSUInteger, PNObjectModificationType) {

    /**
     Represent modification during which additional information can be added or existing can be modified in remote
     object.
     */
    PNObjectUpdateType,

    /**
     Represent modification during which piece or whole object information completely replaced with new data.
     */
    PNObjectReplaceType,

    /**
     Represent modification during which piece of whole object information removed.
     */
    PNObjectDeleteType
};


#pragma mark - Public interface declaration

@interface PNObjectModificationInformation : NSObject


#pragma mark - Properties

/**
 Stores reference on action which has been performed on specified object.
 */
@property (nonatomic, readonly, assign) PNObjectModificationType type;

/**
 Stores reference on unique remote object identifier for which information should be modified.
 */
@property (nonatomic, readonly, copy) NSString *objectIdentifier;

/**
 Stores reference on path at which object should be modified (can be \b nil for root object modification).
 */
@property (nonatomic, readonly, copy) NSString *modificationLocation;

/**
 In case of update or set modification actions stores reference on data which should be used during modification.
 */
@property (nonatomic, readonly, strong) id data;

#pragma mark -


@end
