//
//  PNObjectFetchInformation.m
//  pubnub
//
//  Created by Sergey Mamontov on 7/13/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectFetchInformation+Protected.h"

@implementation PNObjectFetchInformation


#pragma mark - Class methods

+ (PNObjectFetchInformation *)objectFetchInformation:(NSString *)objectInformation path:(NSString *)partialObjectDataPath
                                        snapshotDate:(NSString *)snapshotDate andDataNextPageToken:(NSString *)dataNextPageToken {

    return [[self alloc] initFetchInformation:objectInformation path:partialObjectDataPath snapshotDate:snapshotDate
                         andDataNextPageToken:dataNextPageToken];
}


#pragma mark - Instance methods

- (id)initFetchInformation:(NSString *)objectInformation path:(NSString *)partialObjectDataPath
              snapshotDate:(NSString *)snapshotDate andDataNextPageToken:(NSString *)dataNextPageToken {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        self.objectIdentifier = objectInformation;
        self.partialObjectDataPath = partialObjectDataPath;
        self.snapshotDate = (snapshotDate.length > 1 ? snapshotDate : nil);
        self.dataNextPageToken = dataNextPageToken;
    }


    return self;
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p) <identifier: %@, path: %@, snapshot date: %@, next page token: %@>",
                    NSStringFromClass([self class]), self, self.objectIdentifier, self.partialObjectDataPath,
                    self.snapshotDate, self.dataNextPageToken];
}

#pragma mark -


@end
