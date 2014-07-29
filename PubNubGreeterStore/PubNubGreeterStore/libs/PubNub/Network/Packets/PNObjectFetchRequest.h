//
//  PNObjectFetchRequest.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNBaseRequest.h"


#pragma mark - Public interface declaration

@interface PNObjectFetchRequest : PNBaseRequest


#pragma mark - Class methods

/**
 Construct and return request which allow to fetch whole or partial object from \b PubNub cloud.

 @param objectIdentifier
 String identifier under which information is stored on \b PubNub cloud servers.

 @param partialObjectDataPath
 Is key-path to concrete portion of object stored in \b PubNub cloud.

 @param snapshotDate
 Reference on object snapshot actual for specified date.

 @return instance of \b PNObjectFetchRequest
 */
+ (PNObjectFetchRequest *)objectFetchRequestForIdentifier:(NSString *)objectIdentifier path:(NSString *)partialObjectDataPath
                                          andSnapshotDate:(NSString *)snapshotDate;


#pragma mark - Instance methods

/**
 Initialize and return request which allow to fetch whole or partial object from \b PubNub cloud.

 @param objectIdentifier
 String identifier under which information is stored on \b PubNub cloud servers.

 @param partialObjectDataPath
 Is key-path to concrete portion of object stored in \b PubNub cloud.

 @param snapshotDate
 Reference on object snapshot actual for specified date.

 @return instance of \b PNObjectFetchRequest
 */
- (id)initWithObjectIdentifier:(NSString *)objectIdentifier path:(NSString *)partialObjectDataPath
               andSnapshotDate:(NSString *)snapshotDate;

#pragma mark -


@end
