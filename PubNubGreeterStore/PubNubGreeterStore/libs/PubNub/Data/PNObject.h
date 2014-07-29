//
//  PNObject.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/11/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNDate;


#pragma mark - Public interface declaration

@interface PNObject : NSDictionary


#pragma mark - Properties

/**
 Stores reference on identifier under which this object is stored in \b PubNub cloud.
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 Stores reference on date when this object has been updated or initially retrieved from \b PubNub cloud.
 */
@property (nonatomic, readonly, strong) PNDate *updateDate;

#pragma mark -


@end
