//
//  NSDictionary+PNAdditions.h
//  pubnub
//
//  Created by Sergey Mamontov on 1/11/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface NSDictionary (PNAdditions)


#pragma mark - Instance methods

/**
 Validate provided dictionary and check whether values are: int, float string.

 @return \c YES if provided dictionary conforms to the requirements.
 */
- (BOOL)isValidState;

/**
 Construct from receiver mutable dictionary where every collection inside is mutable as well.

 @return Mutable dictionary with mutable collections inside.
 */
- (NSMutableDictionary *)mutableContent;

#pragma mark -


@end
