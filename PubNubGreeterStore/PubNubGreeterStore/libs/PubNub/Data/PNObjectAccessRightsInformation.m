//
//  PNObjectAccessRightsInformation.m
//  pubnub
//
//  Created by Sergey Mamontov on 7/18/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectAccessRightsInformation+Protected.h"
#import "PNSynchronizationChannel+Protected.h"
#import "PNHelper.h"


#pragma mark Public interface implementation

@implementation PNObjectAccessRightsInformation


#pragma mark - Class methods

+ (PNObjectAccessRightsInformation *)objectAccessRightsInformationFrom:(PNAccessRightsInformation *)accessRightsInformation {
    
    return [[self alloc] initWithAccessRightsInformationFrom:accessRightsInformation];
}

+ (PNObjectAccessRightsInformation *)accessRightsInformationForLevel:(PNAccessRightsLevel)level rights:(PNAccessRights)rights
                                                      applicationKey:(NSString *)subscriptionKey
                                                              object:(NSString *)objectIdentifier
                                                              client:(NSString *)clientAuthorizationKey
                                                        accessPeriod:(NSUInteger)accessPeriodDuration {
    
    return [[self alloc] initWithAccessLevel:level rights:rights applicationKey:subscriptionKey object:objectIdentifier
                                      client:clientAuthorizationKey accessPeriod:accessPeriodDuration];
}


#pragma mark - Instance methods

- (id)initWithAccessRightsInformationFrom:(PNAccessRightsInformation *)accessRightsInformation {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {
        
        self.level = (accessRightsInformation.level == PNChannelAccessRightsLevel ? PNObjectAccessRightsLevel : accessRightsInformation.level);
        self.rights = accessRightsInformation.rights;
        self.subscriptionKey = accessRightsInformation.subscriptionKey;
        self.objectIdentifier = [PNSynchronizationChannel channelForObject:accessRightsInformation.channel.name].objectIdentifier;
        self.authorizationKey = accessRightsInformation.authorizationKey;
        self.accessPeriodDuration = accessRightsInformation.accessPeriodDuration;
    }
    
    
    return self;
}

- (id)initWithAccessLevel:(PNAccessRightsLevel)level rights:(PNAccessRights)rights applicationKey:(NSString *)subscriptionKey
                   object:(NSString *)objectIdentifier client:(NSString *)clientAuthorizationKey
             accessPeriod:(NSUInteger)accessPeriodDuration {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {
        
        self.level = (level == PNChannelAccessRightsLevel ? PNObjectAccessRightsLevel : level);
        self.rights = rights;
        self.subscriptionKey = subscriptionKey;
        self.objectIdentifier = objectIdentifier;
        self.authorizationKey = clientAuthorizationKey;
        self.accessPeriodDuration = accessPeriodDuration;
    }
    
    
    return self;
}

- (BOOL)hasReadRight {
    
    return [PNBitwiseHelper is:self.rights containsBit:PNReadAccessRight];
}

- (BOOL)hasWriteRight {
    
    return [PNBitwiseHelper is:self.rights containsBit:PNWriteAccessRight];
}

- (BOOL)hasAllRights {
    
    return [PNBitwiseHelper is:self.rights strictly:YES containsBits:PNReadAccessRight, PNWriteAccessRight, BITS_LIST_TERMINATOR];
}

- (BOOL)isAllRightsRevoked {
    
    return ![self hasAllRights];
}

- (NSString *)description {
    
    NSMutableString *description = [NSMutableString stringWithFormat:@"%@ (%p) <",
                                    NSStringFromClass([self class]), self];
    
    NSString *level = @"object";
    if (self.level == PNUserAccessRightsLevel) {
        
        level = @"user";
    }
    [description appendFormat:@"level: %@;", level];
    
    NSString *rights = @"none (revoked)";
    if ([self hasReadRight] || [self hasWriteRight]) {
        
        rights = [self hasReadRight] ? @"read" : @"";
        if ([self hasWriteRight]) {
            
            rights = ([rights length] > 0) ? [rights stringByAppendingString:@" / write"] : @"write";
        }
    }
    [description appendFormat:@" rights: %@;", rights];
    
    [description appendFormat:@" application: %@;", self.subscriptionKey];
    
    if (self.level == PNObjectAccessRightsLevel) {
        
        [description appendFormat:@" object: %@;", self.objectIdentifier];
    }
    else if (self.level == PNUserAccessRightsLevel) {
        
        [description appendFormat:@" user: %@;", self.authorizationKey];
        [description appendFormat:@" object: %@;", self.objectIdentifier];
    }
    
    [description appendFormat:@" access period duration: %lu>", (unsigned long)self.accessPeriodDuration];
    
    
    return description;
}

#pragma mark -


@end
