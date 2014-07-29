//
//  PNObjectFetchResponseParser.m
//  pubnub
//
//  Created by Sergey Mamontov on 7/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectFetchResponseParser.h"
#import "PNResponse.h"
#import "NSArray+PNAdditions.h"


#pragma mark Private interface declaration

@interface PNObjectFetchResponseParser ()


#pragma mark - Properties

@property (nonatomic, strong) id data;

#pragma mark -


@end;


#pragma mark - Public interface implementation

@implementation PNObjectFetchResponseParser


#pragma mark - Class methods

+ (id)parserForResponse:(PNResponse *)response {

    NSAssert1(0, @"%s SHOULD BE CALLED ONLY FROM PARENT CLASS", __PRETTY_FUNCTION__);


    return nil;
}


#pragma mark - Instance methods

- (id)initWithResponse:(PNResponse *)response {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        self.data = ([response.response respondsToSelector:@selector(count)] ? [response.response mutableContent] : response.response);
    }


    return self;
}

- (id)parsedData {

    return self.data;
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@ (%p): %@", NSStringFromClass([self class]), self, [self parsedData]];
}

#pragma mark -


@end
