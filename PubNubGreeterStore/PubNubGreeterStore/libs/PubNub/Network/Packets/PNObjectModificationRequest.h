//
//  PNObjectModificationRequest.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNBaseRequest.h"


#pragma mark Class forward

@class PNObjectModificationInformation;


#pragma mark - Public interface declaration

@interface PNObjectModificationRequest : PNBaseRequest


#pragma mark - Class methods

/**
 Create and configure request which is able to change remote object value in \b PubNub cloud.

 @param information
 Reference on instance which describe action and all information required to perform it.

 @return \b PNObjectModificationInformation instance which can be used by \b PubNub client.
 */
+ (PNObjectModificationRequest *)modificationRequestFromInformation:(PNObjectModificationInformation *)information;


#pragma mark - Instance methods

/**
 Initiate and configure request which is able to change remote object value in \b PubNub cloud.

 @param information
 Reference on instance which describe action and all information required to perform it.

 @return \b PNObjectModificationInformation instance which can be used by \b PubNub client.
 */
- (id)initWithInformation:(PNObjectModificationInformation *)information;

#pragma mark -


@end
