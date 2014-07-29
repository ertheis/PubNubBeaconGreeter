//
//  PNObjectAccessRightsCollection+Protected.m
//  pubnub
//
//  Created by Sergey Mamontov on 7/18/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectAccessRightsCollection+Protected.h"
#import "PNObjectAccessRightsInformation+Protected.h"
#import "PNSynchronizationChannel+Protected.h"
#import "PNAccessRightsCollection+Protected.h"
#import "PNObjectAccessRightsInformation.h"
#import "PNAccessRightsInformation.h"
#import "PNHelper.h"


#pragma mark Public interface implementation

@implementation PNObjectAccessRightsCollection


#pragma mark - Class methods

+ (PNObjectAccessRightsCollection *)objectAccessRightsFrom:(PNAccessRightsCollection *)channelAccessRightsInformation {
    
    return [[self alloc] initWithRightsFrom:channelAccessRightsInformation];
}


#pragma mark - Instance methods

- (id)initWithRightsFrom:(PNAccessRightsCollection *)channelAccessRightsInformation {
    
    // Check whether initialization has been successful or not.
    if ((self = [super init])) {
        
        self.applicationKey = channelAccessRightsInformation.applicationKey;
        self.objectsAccessRightsInformation = [NSMutableDictionary dictionary];
        self.clientsAccessRightsInformation = [NSMutableDictionary dictionary];
        
        [self storeConvertedChannelAccessRightsInformation:channelAccessRightsInformation.channelsAccessRightsInformation
                                                        in:self.objectsAccessRightsInformation];
        [self storeConvertedChannelAccessRightsInformation:channelAccessRightsInformation.clientsAccessRightsInformation
                                                        in:self.clientsAccessRightsInformation];
    }
    
    
    return self;
}

- (NSArray *)accessRightsInformationForAllObjects {
    
    return [self.objectsAccessRightsInformation allValues];
}

- (PNObjectAccessRightsInformation *)accessRightsInformationForObject:(NSString *)objectIdentifier {
    
    PNObjectAccessRightsInformation *information = [self.objectsAccessRightsInformation valueForKeyPath:objectIdentifier];
    if (!information) {
        
        information = [PNObjectAccessRightsInformation accessRightsInformationForLevel:PNChannelAccessRightsLevel
                                                                                rights:PNUnknownAccessRights
                                                                        applicationKey:self.applicationKey
                                                                                object:objectIdentifier client:nil
                                                                          accessPeriod:0];
    }
    
    
    return information;
}

- (NSArray *)accessRightsForClientsOnObject:(NSString *)objectIdentifier {
    
    NSString *keyPortion = [NSString stringWithFormat:@"%@.", objectIdentifier];
    NSSet *userInformationKeys = [self.clientsAccessRightsInformation keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        
        return [key rangeOfString:keyPortion].location != NSNotFound;
    }];
    
    
    return [[self.clientsAccessRightsInformation dictionaryWithValuesForKeys:[userInformationKeys allObjects]] allValues];
}

- (NSArray *)accessRightsInformationForAllClientAuthorizationKeys {
    
    return [self.clientsAccessRightsInformation allValues];
}

- (NSArray *)accessRightsInformationForClientAuthorizationKey:(NSString *)clientAuthorizationKey {
    
    // Filter out access rights information with specified client.
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"self.authorizationKey = %@", clientAuthorizationKey];
    
    
    return [[self accessRightsInformationForAllObjects] filteredArrayUsingPredicate:filterPredicate];
}

- (PNObjectAccessRightsInformation *)accessRightsInformationClientAuthorizationKey:(NSString *)clientAuthorizationKey
                                                                          onObject:(NSString *)objectIdentifier {
    
    NSString *userInformationStoreKey = [NSString stringWithFormat:@"%@.%@", objectIdentifier, clientAuthorizationKey];
    PNObjectAccessRightsInformation *clientInformation = [self.clientsAccessRightsInformation valueForKey:userInformationStoreKey];
    
    // Check whether there is no access rights information for specified client or not.
    if (clientInformation == nil) {
        
        clientInformation = [PNObjectAccessRightsInformation accessRightsInformationForLevel:PNUserAccessRightsLevel
                                                                                      rights:PNUnknownAccessRights
                                                                              applicationKey:self.applicationKey
                                                                                      object:objectIdentifier
                                                                                      client:clientAuthorizationKey
                                                                                accessPeriod:0];
        
        [self populateAccessRightsFrom:[self accessRightsInformationForObject:objectIdentifier] to:clientInformation];
    }
    
    
    return clientInformation;
}


#pragma mark - Misc methods

- (void)storeConvertedChannelAccessRightsInformation:(NSDictionary *)channelsAccessRightsInformation
                                                  in:(NSMutableDictionary *)objectsAccessRightsInformationStorage {
    
    [channelsAccessRightsInformation enumerateKeysAndObjectsUsingBlock:^(NSString *entryIdentifier,
                                                                         PNAccessRightsInformation *accessRightsInformation,
                                                                         BOOL *accessRightsInformationEnumeratorStop) {
        
        PNObjectAccessRightsInformation *objectInformation = [PNObjectAccessRightsInformation objectAccessRightsInformationFrom:accessRightsInformation];
        
        NSString *oldUserStorageKey = [NSString stringWithFormat:@"%@.%@", accessRightsInformation.channel.name, accessRightsInformation.authorizationKey];
        if ([entryIdentifier isEqualToString:oldUserStorageKey]) {
            
            entryIdentifier = [NSString stringWithFormat:@"%@.%@", [PNSynchronizationChannel channelForObject:accessRightsInformation.channel.name].objectIdentifier,
                               accessRightsInformation.authorizationKey];
        }
        [objectsAccessRightsInformationStorage setValue:objectInformation forKey:entryIdentifier];
    }];
}

- (void)populateAccessRightsFrom:(PNObjectAccessRightsInformation *)sourceAccessRightsInformation
                              to:(PNObjectAccessRightsInformation *)targetAccessRightsInformation {
    
    // Alter access rights if higher level available and has different access rights which can be used.
    if ([sourceAccessRightsInformation hasReadRight] || [sourceAccessRightsInformation hasWriteRight]) {
        
        unsigned long rights = targetAccessRightsInformation.rights;
        if ([sourceAccessRightsInformation hasAllRights]) {
            
            rights = (PNReadAccessRight | PNWriteAccessRight);
        }
        
        
        if ([sourceAccessRightsInformation hasReadRight] && ![PNBitwiseHelper is:rights containsBit:PNReadAccessRight]) {
            
            [PNBitwiseHelper addTo:&rights bit:PNReadAccessRight];
        }
        
        if ([sourceAccessRightsInformation hasWriteRight] && ![PNBitwiseHelper is:rights containsBit:PNWriteAccessRight]) {
            
            [PNBitwiseHelper addTo:&rights bit:PNWriteAccessRight];
        }
        
        targetAccessRightsInformation.rights = (PNAccessRights)rights;
    }
}

- (NSString *)description {
    
    NSString *indent = @"";
    NSMutableString *descriptionString = [NSMutableString string];
    
    if ([self.objectsAccessRightsInformation count]) {
        
        NSString *oldIndent = [NSString stringWithString:indent];
        [descriptionString appendFormat:@"\n%@Objects:\n", indent];
        
        indent = [indent stringByAppendingString:@"    "];
        [descriptionString appendString:indent];
        NSString *objectsJoinString = [NSString stringWithFormat:@"\n%@", indent];
        [descriptionString appendString:[[self.objectsAccessRightsInformation allValues]
                                         componentsJoinedByString:objectsJoinString]];
        
        indent = oldIndent;
    }
    
    if ([self.clientsAccessRightsInformation count]) {
        
        [descriptionString appendFormat:@"\n%@Clients:\n", indent];
        
        indent = [indent stringByAppendingString:@"    "];
        [descriptionString appendString:indent];
        NSString *clientsJoinString = [NSString stringWithFormat:@"\n%@", indent];
        [descriptionString appendString:[[self.clientsAccessRightsInformation allValues]
                                         componentsJoinedByString:clientsJoinString]];
    }
    
    
    return descriptionString;
}

#pragma mark -


@end
