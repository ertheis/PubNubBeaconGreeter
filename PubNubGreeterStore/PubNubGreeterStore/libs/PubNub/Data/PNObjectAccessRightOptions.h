//
//  PNObjectAccessRightOptions.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/19/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface PNObjectAccessRightOptions : NSObject


#pragma mark - Properties

/**
 Stores access rights level for which request has been made.
 */
@property (nonatomic, readonly, assign) PNAccessRightsLevel level;

/**
 Stores access rights which should be granted to the object which depends on \a 'level' property.
 
 @note This property set only if \b PNAccessRightOptions is used for access rights grant API.
 */
@property (nonatomic, readonly, assign) PNAccessRights rights;

/**
 Stores reference on application identifier key (\a 'subscribe' key) which is used for object access rights manipulation.
 */
@property (nonatomic, readonly, copy) NSString *applicationKey;

/**
 Stores reference on set of unique cloud object identifier for which access rights grant / audit has been made.
 
 @note This property will be set only if \a level is set to: \a PNChannelAccessRightsLevel or \a PNUserAccessRightsLevel.
 */
@property (nonatomic, readonly, strong) NSArray *objectIdentifiers;

/**
 Stores reference on set of clients authorization keys for which access rights has been granted or retrieved.
 
 @note This property will be set only if \a level is set to \a PNUserAccessRightsLevel.
 */
@property (nonatomic, readonly, strong) NSArray *clientsAuthorizationKeys;

/**
 Stores reference on value, which described on how long specified access rights should be granted.
 
 @note This property set only when access rights grant API is used.
 */
@property (nonatomic, readonly, assign) NSUInteger accessPeriodDuration;


#pragma mark - Instance methods

/**
 Check values stored in \a 'rights' property for whether they configured to enable \a 'read' access rights on
 specific object or not.
 
 @return \c 'YES' if request has been made to enable \a 'read' access rights on specific object.
 */
- (BOOL)isEnablingReadAccessRight;

/**
 Check values stored in \a 'rights' property for whether they configured to enable \a 'write' access rights on
 specific object or not.
 
 @return \c 'YES' if request has been made to enable \a 'write' access rights on specific object.
 */
- (BOOL)isEnablingWriteAccessRight;

/**
 Check values stored in \a 'rights' property for whether they configured to enable \a 'write' access rights on
 specific object or not.
 
 @return \c 'YES' if request has been made to enable \a 'write' access rights on specific object.
 */
- (BOOL)isEnablingAllAccessRights;

/**
 Check values stored in \a 'rights' property for whether they configured to revoke access rights on specific object or not.
 
 @return \c 'YES' if request has been made to revoke access rights on specific object.
 */
- (BOOL)isRevokingAccessRights;

#pragma mark -


@end
