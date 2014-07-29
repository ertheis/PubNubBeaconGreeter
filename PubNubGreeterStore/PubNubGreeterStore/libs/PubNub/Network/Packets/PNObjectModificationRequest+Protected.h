//
//  PNObjectModificationRequest+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/17/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectModificationRequest.h"


#pragma mark Private interface declaration

@interface PNObjectModificationRequest ()


#pragma mark - Properties

/**
 Stores reference on instance which describes required parameters for request.
 */
@property (nonatomic, strong) PNObjectModificationInformation *information;

/**
 Stores reference on JSON serialized message
 */
@property (nonatomic, strong) NSString *preparedMessage;


#pragma mark -


@end
