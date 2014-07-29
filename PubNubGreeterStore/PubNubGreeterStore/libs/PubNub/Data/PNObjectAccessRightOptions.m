//
//  PNObjectAccessRightOptions.m
//  pubnub
//
//  Created by Sergey Mamontov on 7/19/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectAccessRightOptions+Protected.h"
#import "PNHelper.h"


#pragma mark Public interface implementation

@implementation PNObjectAccessRightOptions


#pragma mark - Class methods

+ (PNObjectAccessRightOptions *)accessRightOptionsFrom:(PNAccessRightOptions *)channelAccessRightsOptions {
    
    return [[self alloc] initAccessRightOptionsFrom:channelAccessRightsOptions];
}


#pragma mark - Instance methods

- (id)initAccessRightOptionsFrom:(PNAccessRightOptions *)channelAccessRightsOptions {
    
    // Check whether initialization has been successful or not
    if ((self = [super init])) {
        
        self.level = channelAccessRightsOptions.level;
        self.rights = channelAccessRightsOptions.rights;
        self.applicationKey = channelAccessRightsOptions.applicationKey;
        self.objectIdentifiers = [channelAccessRightsOptions.channels valueForKey:@"objectIdentifier"];
        self.clientsAuthorizationKeys = channelAccessRightsOptions.clientsAuthorizationKeys;
        self.accessPeriodDuration = channelAccessRightsOptions.accessPeriodDuration;
    }
    
    
    return self;
}

- (BOOL)isEnablingReadAccessRight {
    
    return [PNBitwiseHelper is:self.rights containsBit:PNReadAccessRight];
}

- (BOOL)isEnablingWriteAccessRight {
    
    return [PNBitwiseHelper is:self.rights containsBit:PNWriteAccessRight];
}

- (BOOL)isEnablingAllAccessRights {
    
    return [PNBitwiseHelper is:self.rights strictly:YES containsBits:PNReadAccessRight, PNWriteAccessRight, BITS_LIST_TERMINATOR];
}

- (BOOL)isRevokingAccessRights {
    
    return ![self isEnablingReadAccessRight] && ![self isEnablingWriteAccessRight];
}

- (NSString *)description {
    
    NSMutableString *description = [NSMutableString stringWithFormat:@"%@ (%p) <",
                                    NSStringFromClass([self class]), self];
    
    NSString *level = @"channel";
    if (self.level == PNUserAccessRightsLevel) {
        
        level = @"user";
    }
    [description appendFormat:@"level: %@;", level];
    
    NSString *rights = @"none (revoked)";
    if ([self isEnablingReadAccessRight] || [self isEnablingWriteAccessRight]) {
        
        rights = [self isEnablingReadAccessRight] ? @"read" : @"";
        if ([self isEnablingWriteAccessRight]) {
            
            rights = ([rights length] > 0) ? [rights stringByAppendingString:@" / write"] : @"write";
        }
    }
    [description appendFormat:@" rights: %@;", rights];
    
    [description appendFormat:@" application: %@;", self.applicationKey];
    
    if (self.level == PNObjectAccessRightsLevel) {
        
        [description appendFormat:@" objects: %@;", self.objectIdentifiers];
    }
    else if (self.level == PNUserAccessRightsLevel) {
        
        [description appendFormat:@" objects: %@;", self.objectIdentifiers];
        [description appendFormat:@" users: %@;", self.clientsAuthorizationKeys];
    }
    
    [description appendFormat:@" access period duration: %lu>", (unsigned long)self.accessPeriodDuration];
    
    
    return description;
}

#pragma mark -


@end
