//
//  PNObjectModificationParser.m
//  pubnub
//
//  Created by Sergey Mamontov on 7/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectModificationParser.h"
#import "PNObjectModificationInformation.h"
#import "PNResponse+Protected.h"


#pragma mark Private interface declaration

@interface PNObjectModificationParser ()


#pragma mark - Properties

@property (nonatomic, strong) PNObjectModificationInformation *information;

#pragma mark -


@end;


#pragma mark - Public interface implementation

@implementation PNObjectModificationParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {

    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);


    return nil;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization successful or not
    if ((self = [super init])) {


        self.information = response.additionalData;
    }


    return self;
}

- (id)parsedData {

    return self.information;
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p): %@", NSStringFromClass([self class]), self, [self parsedData]];
}

#pragma mark -


@end
