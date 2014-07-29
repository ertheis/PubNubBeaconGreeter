//
//  PNObjectFetchRequest+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectFetchRequest.h"


#pragma mark Class forward

@class PNObjectFetchInformation;


#pragma mark - Private interface declaration

@interface PNObjectFetchRequest ()


#pragma mark - Properties

/**
 Stores reference on object which provide all information required for remote object retrieval process.
 */
@property (nonatomic, strong) PNObjectFetchInformation *information;


#pragma mark - Instance methods

/**
 Update next page token value.
 */
- (void)setDataNextPageToken:(NSString *)dataNextPageToken;

#pragma mark -


@end
