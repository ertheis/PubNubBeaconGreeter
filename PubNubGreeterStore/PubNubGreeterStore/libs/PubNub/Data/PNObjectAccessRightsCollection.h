//
//  PNObjectAccessRightsCollection.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/18/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface PNObjectAccessRightsCollection : NSObject


#pragma mark - Instance methods

/**
 Fetch access rights information for all cloud objects.
 
 @return List of \b PNObjectAccessRightsInformation instances each of which describe it's own object access rights.
 */
- (NSArray *)accessRightsInformationForAllObjects;

/**
 Fetch access rights information for specific cloud \a 'object'.
 
 @param objectIdentifier
 Unique cloud object identifier for which access information should be pulled out.
 
 @return \b PNObjectAccessRightsInformation instance which will describe concrete cloud object access rights.
 
 @note If \b PNObjectAccessRightsInformation instance represents \a 'user' access rights level,
 it can't provide information about higher levels (cloud \a 'object' levels).
 
 @note In case if specified \c object can't be found in this collection, \b PNObjectAccessRightsInformation instance
 will be created for it and access rights will be computed, computed values will be \a 'PNUnknownAccessRights'.
 
 @note During computation even higher access rights level may take part (for example for \a 'user' level can be used
 values from cloud \a 'object' level if available).
 */
- (PNObjectAccessRightsInformation *)accessRightsInformationForObject:(NSString *)objectIdentifier;

/**
 Fetch access rights information for all users associalted with specified cloud object.
 
 @param objectIdentifier
 Unique cloud object identifier for which access information should be pulled out.
 
 @return List of \b PNObjectAccessRightsInformation instances each of which describe it's own user access rights.
 */
- (NSArray *)accessRightsForClientsOnObject:(NSString *)objectIdentifier;

/**
 Fetch access rights information for all users.
 
 @return List of \b PNObjectAccessRightsInformation instances each of which describe it's own user access rights.
 */
- (NSArray *)accessRightsInformationForAllClientAuthorizationKeys;

/**
 Fetch access rights information for specific user on all cloud objects.
 
 @return List of \b PNObjectAccessRightsInformation instances each of which describe it's own user access rights.
 */
- (NSArray *)accessRightsInformationForClientAuthorizationKey:(NSString *)clientAuthorizationKey;

/**
 Fetch access rights information for specific \a 'user' on concrete cloud \a 'object'.
 
 @param objectIdentifier
 Unique cloud object identifier for which access information should be pulled out.
 
 @param clientAuthorizationKey
 \a NSString instance which represent client's authorization key which has been used during access rights grant or
 for which access rights should be pulled out.
 
 @note In case if specified cloud \c object and / or \c clientAuthorizationKey can't be found in this collection,
 \b PNObjectAccessRightsInformation instance will be created for them and will be computed access rights will be computed
 basing on higher level information. In case if requested \c user access information can't be found, computed values will 
 be \a 'PNUnknownAccessRights'.
 
 @note During computation even higher access rights level may take part (for example for \a 'user' level can be used
 values from cloud \a 'object').
 */
- (PNObjectAccessRightsInformation *)accessRightsInformationClientAuthorizationKey:(NSString *)clientAuthorizationKey
                                                                          onObject:(NSString *)objectIdentifier;

#pragma mark -


@end
