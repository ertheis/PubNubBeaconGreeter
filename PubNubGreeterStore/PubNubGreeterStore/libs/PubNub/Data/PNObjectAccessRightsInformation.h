//
//  PNObjectAccessRightsInformation.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/18/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNStructures.h"


#pragma mark Public interface declaration

@interface PNObjectAccessRightsInformation : NSObject


#pragma mark - Properties

/**
 Stores access rights level for which this object has been created.
 */
@property (nonatomic, readonly, assign) PNAccessRightsLevel level;

/**
 Stores access rights bit mask which describe whether there is \a 'read' / \a 'write' rights on object specified by
 access level
 */
@property (nonatomic, readonly, assign) PNAccessRights rights;

/**
 Stores reference on key which is used to identify application (\a 'subscription' key).
 */
@property (nonatomic, readonly, copy) NSString *subscriptionKey;

/**
 Stores reference on cloud object for which access rights has been granted or retrieved.
 */
@property (nonatomic, readonly, strong) NSString *objectIdentifier;

/**
 Stores reference on authorization key for which access rights has been granted or retrieved.
 
 @note This property will be set only if \a level is set to \a PNUserAccessRightsLevel.
 */
@property (nonatomic, readonly, copy) NSString *authorizationKey;

/**
 Stores reference on value, which described on how long specified access rights has been granted.
 */
@property (nonatomic, readonly, assign) NSUInteger accessPeriodDuration;


#pragma mark - Instance methods

/**
 Check access rights bit mask and return whether \a 'read' access permission is granted or not.
 
 @return \c YES if \b PNReadAccessRight bit is set in \a 'rights' property.
 */
- (BOOL)hasReadRight;

/**
 Check access rights bit mask and return whether \a 'write' access permission is granted or not.
 
 @return \c YES if \b PNWriteAccessRight bit is set in \a 'rights' property.
 */
- (BOOL)hasWriteRight;

/**
 Check access rights bit mask and return whether \a 'write' access permission is granted or not.
 
 @return \c YES if both \b PNReadAccessRight and \b PNWriteAccessRight bits are set in \a 'rights' property.
 */
- (BOOL)hasAllRights;

/**
 Check whether all rights has been revoked or not.
 
 @return \c YES if both \b PNReadAccessRight and \b PNWriteAccessRight bits not set in \a 'rights' property.
 */
- (BOOL)isAllRightsRevoked;

#pragma mark -


@end
