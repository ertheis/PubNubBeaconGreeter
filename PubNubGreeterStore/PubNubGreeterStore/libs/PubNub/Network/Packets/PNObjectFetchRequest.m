//
//  PNObjectFetchRequest.m
//  pubnub
//
//  Created by Sergey Mamontov on 7/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectFetchRequest+Protected.h"
#import "PNObjectFetchInformation+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "PubNub+Protected.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub object fetch request must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark - Public interface implementation

@implementation PNObjectFetchRequest


#pragma mark - Class methods

+ (PNObjectFetchRequest *)objectFetchRequestForIdentifier:(NSString *)objectIdentifier path:(NSString *)partialObjectDataPath
                                          andSnapshotDate:(NSString *)snapshotDate {

    return [[self alloc] initWithObjectIdentifier:objectIdentifier path:partialObjectDataPath andSnapshotDate:snapshotDate];
}


#pragma mark - Instance methods

- (id)initWithObjectIdentifier:(NSString *)objectIdentifier path:(NSString *)partialObjectDataPath
               andSnapshotDate:(NSString *)snapshotDate {

    // Check whether initialization has been successful or not
    if ((self = [super init])) {

        self.information = [PNObjectFetchInformation objectFetchInformation:objectIdentifier
                                                                       path:partialObjectDataPath
                                                               snapshotDate:snapshotDate
                                                       andDataNextPageToken:nil];
    }


    return self;
}

- (void)setDataNextPageToken:(NSString *)dataNextPageToken {

    self.information.dataNextPageToken = dataNextPageToken;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.objectFetchCallback;
}

- (NSString *)resourcePath {

    // Composing parameters list
    NSMutableString *parameters = [NSMutableString stringWithFormat:@"?callback=%@_%@", [self callbackMethodName],
                                                                    self.shortIdentifier];

    // Check whether information about snapshot date available or not.
    if (self.information.snapshotDate) {

        [parameters appendFormat:@"&obj_at=%@", self.information.snapshotDate];
    }


    // Checking whether there is offset which should be used or not.
    if (self.information.dataNextPageToken) {

        [parameters appendFormat:@"&start_at=%@", self.information.dataNextPageToken];
    }

    NSString *partialObjectDataPath = [self.information.partialObjectDataPath stringByReplacingOccurrencesOfString:@"." withString:@"/"];

    return [NSString stringWithFormat:@"/v1/datasync/sub-key/%@/obj-id/%@%@%@%@&method=GET&pnsdk=%@",
                    [[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString],
                    [self.information.objectIdentifier percentEscapedString],
                    (partialObjectDataPath ? [NSString stringWithFormat:@"/%@", partialObjectDataPath] : @""),
                    parameters, ([self authorizationField]?[NSString stringWithFormat:@"&%@", [self authorizationField]]:@""),
                    [self clientInformationField]];
}

- (NSString *)debugResourcePath {

    NSMutableArray *resourcePathComponents = [[[self resourcePath] componentsSeparatedByString:@"/"] mutableCopy];
    [resourcePathComponents replaceObjectAtIndex:4 withObject:PNObfuscateString([[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString])];

    return [resourcePathComponents componentsJoinedByString:@"/"];
}

#pragma mark -


@end
