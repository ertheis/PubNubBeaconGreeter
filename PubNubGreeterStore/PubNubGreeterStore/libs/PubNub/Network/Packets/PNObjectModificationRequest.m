//
//  PNObjectModificationRequest.m
//  pubnub
//
//  Created by Sergey Mamontov on 7/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectModificationRequest+Protected.h"
#import "PNObjectModificationInformation+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "PubNub+Protected.h"


#pragma mark - Public interface implementation

@implementation PNObjectModificationRequest


#pragma mark - Class methods

+ (PNObjectModificationRequest *)modificationRequestFromInformation:(PNObjectModificationInformation *)information {

    return [[self alloc] initWithInformation:information];
}


#pragma mark - Instance methods

- (id)initWithInformation:(PNObjectModificationInformation *)information {

    // Check whether initialization has been successful or not.
    if ((self = [super init])) {

        self.information = information;
        self.preparedMessage = (self.information.data ? [PNJSONSerialization stringFromJSONObject:self.information.data] : nil);
    }


    return self;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.objectModificationCallback;
}

- (PNRequestHTTPMethod)HTTPMethod {

    PNRequestHTTPMethod HTTPMethod = PNRequestPATCHMethod;
    if (self.information.type == PNObjectReplaceType) {

        HTTPMethod = PNRequestPUTMethod;
    }
    else if (self.information.type == PNObjectDeleteType) {

        HTTPMethod = PNRequestDELETEMethod;
    }


    return HTTPMethod;
}

- (NSData *)POSTBody {

    return [self.preparedMessage dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)resourcePath {

    NSString *partialObjectDataPath = [[self.information.modificationLocation percentEscapedString] stringByReplacingOccurrencesOfString:@"."
                                                                                                                              withString:@"/"];

    return [NSString stringWithFormat:@"/v1/datasync/sub-key/%@/pub-key/%@/obj-id/%@%@?callback=%@_%@%@&method=%@&pnsdk=%@",
                    [[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString],
                    [[PubNub sharedInstance].configuration.publishKey percentEscapedString],
                    [self.information.objectIdentifier percentEscapedString],
                    (partialObjectDataPath ? [NSString stringWithFormat:@"/%@", partialObjectDataPath] : @""),
                    [self callbackMethodName], self.shortIdentifier,
                    ([self authorizationField] ? [NSString stringWithFormat:@"&%@", [self authorizationField]] : @""),
                    [self HTTPMethodName], [self clientInformationField]];
}

- (NSString *)debugResourcePath {

    NSMutableArray *resourcePathComponents = [[[self resourcePath] componentsSeparatedByString:@"/"] mutableCopy];
    [resourcePathComponents replaceObjectAtIndex:4 withObject:PNObfuscateString([[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString])];
    [resourcePathComponents replaceObjectAtIndex:6 withObject:PNObfuscateString([[PubNub sharedInstance].configuration.publishKey percentEscapedString])];

    return [resourcePathComponents componentsJoinedByString:@"/"];
}

#pragma mark -


@end
