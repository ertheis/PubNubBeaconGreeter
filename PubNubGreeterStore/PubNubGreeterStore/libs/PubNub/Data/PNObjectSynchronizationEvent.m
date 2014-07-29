//
//  PNObjectSynchronizationEvent.m
//  pubnub
//
//  Created by Sergey Mamontov on 7/13/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectSynchronizationEvent+Protected.h"


#pragma mark Structures

struct PNObjectSynchronizationEventDataKeysStruct PNObjectSynchronizationEventDataKeys = {
    .action = @"action",
    .status = @"status",
    .transactionIdentifier = @"trans_id",
    .timeToken = @"timetoken",
    .location = @"location",
    .value = @"value"
};


#pragma mark - Public interface implementation

@implementation PNObjectSynchronizationEvent


#pragma mark - Class methods

+ (PNObjectSynchronizationEvent *)synchronizationEvent:(PNObjectSynchronizationEventType)type forObject:(NSString *)objectIdentifier
                                 transactionIdentifier:(NSString *)transactionIdentifier atLocation:(NSString *)changeLocation
                                            changeDate:(NSString *)changeDate andData:(id)changedData {

    return [[self alloc] initWithEvent:type forObject:objectIdentifier transactionIdentifier:transactionIdentifier
                            atLocation:changeLocation changeDate:changeDate andData:changedData];
}

+ (PNObjectSynchronizationEvent *)synchronizationEventForObject:(NSString *)objectIdentifier atPath:(NSString *)changeLocation
                                                 dromDictionary:(NSDictionary *)event {

    PNObjectSynchronizationEventType type = PNObjectUpdateEvent;
    if ([event objectForKey:PNObjectSynchronizationEventDataKeys.action] != nil) {

        if ([[event valueForKey:PNObjectSynchronizationEventDataKeys.action] isEqualToString:@"delete"]) {

            type = PNObjectDeleteEvent;
        }
    }
    else if ([event objectForKey:PNObjectSynchronizationEventDataKeys.status]) {

        if ([[event valueForKey:PNObjectSynchronizationEventDataKeys.status] isEqualToString:@"complete"]) {

            type = PNObjectCompleteEvent;
        }
    }

    if (!changeLocation && [event objectForKey:PNObjectSynchronizationEventDataKeys.location] != nil) {

        changeLocation = [event objectForKey:PNObjectSynchronizationEventDataKeys.location];
    }


    return [[self alloc] initWithEvent:type forObject:objectIdentifier
                 transactionIdentifier:[event objectForKey:PNObjectSynchronizationEventDataKeys.transactionIdentifier]
                            atLocation:changeLocation
                            changeDate:[event objectForKey:PNObjectSynchronizationEventDataKeys.timeToken]
                               andData:[event objectForKey:PNObjectSynchronizationEventDataKeys.value]];
}

+ (PNObjectSynchronizationEvent *)synchronizationCompletionFromEvent:(PNObjectSynchronizationEvent *)event {
    
    return [self synchronizationEvent:PNObjectCompleteEvent forObject:event.objectIdentifier
                transactionIdentifier:event.eventTransactionIdentifier atLocation:event.changeLocation
                           changeDate:event.changeDate andData:event.changedData];
}

+ (BOOL)isSynchronizationEvent:(NSDictionary *)eventPayload {

    BOOL isSynchronizationEvent = ([eventPayload objectForKey:PNObjectSynchronizationEventDataKeys.action] != nil &&
                [eventPayload objectForKey:PNObjectSynchronizationEventDataKeys.transactionIdentifier] != nil &&
                [eventPayload objectForKey:PNObjectSynchronizationEventDataKeys.timeToken] != nil &&
                [eventPayload objectForKey:PNObjectSynchronizationEventDataKeys.location] != nil);

    BOOL isTransactionNotificationEvent = ([eventPayload objectForKey:PNObjectSynchronizationEventDataKeys.status] != nil &&
                    [eventPayload objectForKey:PNObjectSynchronizationEventDataKeys.timeToken] != nil &&
                    [eventPayload objectForKey:PNObjectSynchronizationEventDataKeys.transactionIdentifier] != nil);


    return (isSynchronizationEvent || isTransactionNotificationEvent);
}

+ (NSString *)initializationTransactionIdentifier {
    
    return @"init";
}


#pragma mark - Instance methods

- (id)initWithEvent:(PNObjectSynchronizationEventType)type forObject:(NSString *)objectIdentifier
transactionIdentifier:(NSString *)transactionIdentifier atLocation:(NSString *)changeLocation
           changeDate:(NSString *)changeDate andData:(id)changedData {

    // Check whether initialization has been successful or not.
    if ((self = [super init])) {

        self.type = type;
        self.objectIdentifier = objectIdentifier;
        self.eventTransactionIdentifier = (type == PNObjectInitEvent ? [[self class] initializationTransactionIdentifier] : transactionIdentifier);
        NSArray *pathComponents = [changeLocation componentsSeparatedByString:@"."];
        if ([pathComponents count] > 1) {

            pathComponents = [pathComponents subarrayWithRange:(NSRange){.location = 1, .length = ([pathComponents count] - 1)}];
            changeLocation = [pathComponents componentsJoinedByString:@"."];
        }
        self.changeLocation = changeLocation;
        self.changeDate = (changeDate ? changeDate :
                                        PNStringFromUnsignedLongLongNumber([[PNDate dateWithDate:[NSDate date]] timeToken]));
        self.changedData = changedData;
    }


    return self;
}

- (NSString *)description {
    
    NSString *type = @"complete";
    if (self.type == PNObjectInitEvent) {
        
        type = @"init";
    }
    else if (self.type == PNObjectUpdateEvent) {
        
        type = @"update";
    }
    else if (self.type == PNObjectDeleteEvent) {
        
        type = @"delete";
    }
    
    
    return [NSString stringWithFormat:@"%@(%p) <event: %@; object: %@; date: %@; transaction: %@; location: %@>", NSStringFromClass([self class]),
            self, type, self.objectIdentifier, self.changeDate, self.eventTransactionIdentifier, self.changeLocation];
}

#pragma mark -


@end
