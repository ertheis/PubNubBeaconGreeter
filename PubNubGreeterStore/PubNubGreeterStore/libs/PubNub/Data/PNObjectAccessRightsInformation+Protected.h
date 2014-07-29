//
//  PNObjectAccessRightsInformation+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/19/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectAccessRightsInformation.h"


#pragma mark Class forward

@class PNAccessRightsInformation;


#pragma mark - Private interface declaration

@interface PNObjectAccessRightsInformation ()


#pragma mark - Properties

@property (nonatomic, assign) PNAccessRightsLevel level;
@property (nonatomic, assign) PNAccessRights rights;
@property (nonatomic, copy) NSString *subscriptionKey;
@property (nonatomic, strong) NSString *objectIdentifier;
@property (nonatomic, copy) NSString *authorizationKey;
@property (nonatomic, assign) NSUInteger accessPeriodDuration;


#pragma mark - Class methods

/**
 Construct instance based on application / channel / user access information.
 
 @param accessRightsInformation
 Reference on original access rights information instance from which data should be pulled out.
 
 @return Ready to use \b PNObjectAccessRightsInformation instance.
 */
+ (PNObjectAccessRightsInformation *)objectAccessRightsInformationFrom:(PNAccessRightsInformation *)accessRightsInformation;

/**
 Construct data object which will be used to represent access rights with specified set of options.
 
 @param level
 Access rights level: PNObjectAccessRightsLevel, PNUserAccessRightsLevel.
 This is level for which access rights has been granted or retrieved.
 
 @param rights
 This is bit mask which describe what exactly access rights has been granted: PNUnknownAccessRights,
 PNReadAccessRight, PNWriteAccessRight, PNNoAccessRights.
 
 @param subscriptionKey
 This is the key which identify application which is used for cloud objects access rights manipulation.
 
 @param objectIdentifier
 Reference on unique cloud object identifier for which access rights has been granted / retrieved.
 
 @param authorizationKey
 If \c level is set to \a PNUserAccessRightsLevel this parameter will contain authorization key which will allow
 to identify concrete user.
 
 @param accessPeriodDuration
 This is period for which \c rights are valid. After it ends, access rights will be revoked.
 
 @return reference on initialized \b PNObjectAccessRightsInformation instance which will allow to identify and review
 access rights information.
 */
+ (PNObjectAccessRightsInformation *)accessRightsInformationForLevel:(PNAccessRightsLevel)level rights:(PNAccessRights)rights
                                                      applicationKey:(NSString *)subscriptionKey
                                                              object:(NSString *)objectIdentifier
                                                              client:(NSString *)clientAuthorizationKey
                                                        accessPeriod:(NSUInteger)accessPeriodDuration;


#pragma mark - Instance methods

/**
 Initialize instance based on application / channel / user access information.
 
 @param accessRightsInformation
 Reference on original access rights information instance from which data should be pulled out.
 
 @return Ready to use \b PNObjectAccessRightsInformation instance.
 */
- (id)initWithAccessRightsInformationFrom:(PNAccessRightsInformation *)accessRightsInformation;

/**
 Initialize data object which will be used to represent access rights with specified set of options.
 
 @param level
 Access rights level: PNObjectAccessRightsLevel, PNUserAccessRightsLevel.
 This is level for which access rights has been granted or retrieved.
 
 @param rights
 This is bit mask which describe what exactly access rights has been granted: PNUnknownAccessRights,
 PNReadAccessRight, PNWriteAccessRight, PNNoAccessRights.
 
 @param subscriptionKey
 This is the key which identify application which is used for cloud objects access rights manipulation.
 
 @param objectIdentifier
 Reference on unique cloud object identifier for which access rights has been granted / retrieved.
 
 @param authorizationKey
 If \c level is set to \a PNUserAccessRightsLevel this parameter will contain authorization key which will allow
 to identify concrete user.
 
 @param accessPeriodDuration
 This is period for which \c rights are valid. After it ends, access rights will be revoked.
 
 @return reference on initialized \b PNObjectAccessRightsInformation instance which will allow to identify and review
 access rights information.
 */
- (id)initWithAccessLevel:(PNAccessRightsLevel)level rights:(PNAccessRights)rights applicationKey:(NSString *)subscriptionKey
                   object:(NSString *)objectIdentifier client:(NSString *)clientAuthorizationKey
             accessPeriod:(NSUInteger)accessPeriodDuration;

#pragma mark -


@end
