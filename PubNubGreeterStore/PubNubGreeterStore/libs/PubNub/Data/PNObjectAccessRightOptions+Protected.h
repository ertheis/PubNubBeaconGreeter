//
//  PNObjectAccessRightOptions+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/19/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectAccessRightOptions.h"


#pragma mark Class forwared

@class PNAccessRightOptions;



#pragma mark - Private interface declaration

@interface PNObjectAccessRightOptions ()


#pragma mark - Properties

@property (nonatomic, assign) PNAccessRightsLevel level;
@property (nonatomic, assign) PNAccessRights rights;
@property (nonatomic, copy) NSString *applicationKey;
@property (nonatomic, strong) NSArray *objectIdentifiers;
@property (nonatomic, strong) NSArray *clientsAuthorizationKeys;
@property (nonatomic, assign) NSUInteger accessPeriodDuration;


#pragma mark - Class methods

/**
 Construct object access rights request information instance from existing instance which describes same request for channels.
 
 @param channelAccessRightsOptions
 Reference on \b PNAccessRightsCollection channel request options which should be converted into object information.
 
 @return Ready to use \b PNObjectAccessRightOptions instance.
 */
+ (PNObjectAccessRightOptions *)accessRightOptionsFrom:(PNAccessRightOptions *)channelAccessRightsOptions;


#pragma mark - Instance methods

/**
 Initialize object access rights request information instance from existing instance which describes same request for channels.
 
 @param channelAccessRightsOptions
 Reference on \b PNAccessRightsCollection channel request options which should be converted into object information.
 
 @return Ready to use \b PNObjectAccessRightOptions instance.
 */
- (id)initAccessRightOptionsFrom:(PNAccessRightOptions *)channelAccessRightsOptions;

#pragma mark -


@end
