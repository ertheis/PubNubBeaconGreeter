//
//  PNObjectModificationInformation.m
//  pubnub
//
//  Created by Sergey Mamontov on 7/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectModificationInformation+Protected.h"


#pragma mark Public interface implementation

@implementation PNObjectModificationInformation


#pragma mark - Class methods

+ (PNObjectModificationInformation *)modificationInformation:(PNObjectModificationType)type forObject:(NSString *)objectIdentifier
                                                  atLocation:(NSString *)modificationLocation andData:(id)data {

    return [[self alloc] initModification:type forObject:objectIdentifier atLocation:modificationLocation andData:data];
}


#pragma mark - Instance methods

- (id)initModification:(PNObjectModificationType)type forObject:(NSString *)objectIdentifier atLocation:(NSString *)modificationLocation
               andData:(id)data {

    // Check whether initialization has been successful or not.
    if ((self = [super init])) {

        self.type = type;
        self.objectIdentifier = objectIdentifier;
        self.modificationLocation = modificationLocation;
        self.data = data;
    }


    return self;
}

- (NSString *)description {

    NSString *modificationType = @"update";
    if (self.type == PNObjectDeleteType) {

        modificationType = @"delete";
    }
    else if (self.type == PNObjectReplaceType) {

        modificationType = @"replace";
    }


    return [NSString stringWithFormat:@"%@ (%p) <action: %@, object: %@, location: %@, data: %@>",
                    NSStringFromClass([self class]), self, modificationType, self.objectIdentifier,
                    self.modificationLocation, self.data];
}

#pragma mark -


@end
