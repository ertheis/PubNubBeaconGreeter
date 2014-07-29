//
//  PNObjectFetchInformation.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/13/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface PNObjectFetchInformation : NSObject


#pragma mark - Properties

/**
 Stores reference on remote object identifier which should be fetched from \b PubNub cloud.
 */
@property (nonatomic, readonly, copy) NSString *objectIdentifier;

/**
 Stores reference on remote object sub-path from which part of information should be retrieved.
 */
@property (nonatomic, readonly, copy) NSString *partialObjectDataPath;

/**
 Stores reference on token which should be used during remote object fetch to get next portion of object data from
 cloud.
 */
@property (nonatomic, readonly, copy) NSString *dataNextPageToken;

/**
 Stores reference on object snapshot actual for specified date.
 */
@property (nonatomic, readonly, copy) NSString *snapshotDate;

#pragma mark -


@end
