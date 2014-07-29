/**

 @author Sergey Mamontov
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNCache.h"
#import "NSMutableDictionary+PNAdditions.h"
#import "PNObjectSynchronizationEvent.h"
#import "PNObject+Protected.h"
#import "PNChannel.h"
#import "PNObjectSynchronizationEvent+Protected.h"


#pragma mark Private interface declaration

@interface PNCache ()

#pragma mark - Properties

/**
 Unified storage for cached data across all channels which is in use by client and developer.
 */
@property (nonatomic, strong) NSMutableDictionary *stateCache;

/**
 Storage which store local copies of objects from \b PubNub cloud.
 */
@property (nonatomic, strong) NSMutableDictionary *objects;

/**
 Storage which is used to store list of changes which should be applied to the object as soon as it's synchronization
 will be completed.
 */
@property (nonatomic, strong) NSMutableDictionary *objectUpdates;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNCache


#pragma mark - Instance methods

- (id)init {

    // Check whether initialization has been successful or not
    if ((self = [super init])) {

        self.stateCache = [NSMutableDictionary dictionary];
        self.objects = [NSMutableDictionary dictionary];
        self.objectUpdates = [NSMutableDictionary dictionary];
    }


    return self;
}


#pragma mark - State management method

- (NSDictionary *)state {

    return ([self.stateCache count] ? [self.stateCache copy] : nil);
}

- (NSDictionary *)stateMergedWithState:(NSDictionary *)state {
    
    NSMutableDictionary *cleanedState = (self.stateCache ? [self.stateCache mutableCopy] : [NSMutableDictionary dictionary]);
    
    [state enumerateKeysAndObjectsUsingBlock:^(NSString *channelName, NSDictionary *channelState,
                                               BOOL *channelStateEnumeratorStop) {
        
        if ([cleanedState valueForKey:channelName] != nil) {
            
            // Ensure that there is not empty dictionary (if dictionary for channel is empty, it mean that
            // user want to remove state from specific channel).
            if ([channelState count]) {
                
                NSMutableDictionary *oldChannelState = [[cleanedState valueForKey:channelName] mutableCopy];
                [channelState enumerateKeysAndObjectsUsingBlock:^(NSString *stateName, id stateData,
                                                                  BOOL *stateDataEnumeratorStop) {
                    
                    // In case if provided data is 'nil' it should be removed from previous state dictionary.
                    if ([stateData isKindOfClass:[NSNull class]]) {
                        
                        [oldChannelState removeObjectForKey:stateName];
                    }
                    else {
                        
                        [oldChannelState setValue:stateData forKey:stateName];
                    }
                }];
                
                if ([oldChannelState count]) {
                    
                    [cleanedState setValue:oldChannelState forKey:channelName];
                }
            }
        }
        // Ensure that there is not empty dictionary (if dictionary for channel is empty, it mean that
        // user want to remove state from specific channel).
        else if ([channelState count]){
            
            [cleanedState setValue:channelState forKey:channelName];
        }
    }];
    
    
    return cleanedState;
}

- (void)storeClientState:(NSDictionary *)clientState forChannel:(PNChannel *)channel {

    if (clientState) {

        if (channel) {
            
            [self.stateCache setValue:clientState forKey:channel.name];
        }
        else {
            
            [clientState enumerateKeysAndObjectsUsingBlock:^(NSString *channelName, NSDictionary *channelState,
                                                             BOOL *channelsStateEnumeratorStop) {
                
                [self.stateCache setValue:channelState forKey:channelName];
            }];
        }
    }
    else {

        [self purgeStateForChannel:channel];
    }
}

- (void)storeClientState:(NSDictionary *)clientState forChannels:(NSArray *)channels {
    
    if (clientState) {
        
        NSArray *channelNames = [channels valueForKey:@"name"];
        NSArray *channelsWithState = [clientState allKeys];
        
        [channelsWithState enumerateObjectsUsingBlock:^(NSString *channelName, NSUInteger idx, BOOL *stop) {
            
            if ([channelNames containsObject:channelName] || [self.stateCache valueForKey:channelName] != nil) {
                
                [self.stateCache setValue:[clientState valueForKey:channelName] forKey:channelName];
            }
        }];
    }
    else {
        
        [self purgeStateForChannels:channels];
    }
}

- (NSDictionary *)stateForChannel:(PNChannel *)channel {

    return (channel ? [self.stateCache valueForKey:channel.name] : nil);
}

- (NSDictionary *)stateForChannels:(NSArray *)channels {

    NSMutableSet *channelsSet = [NSMutableSet setWithArray:[channels valueForKey:@"name"]];
    [channelsSet intersectSet:[NSSet setWithArray:[self.stateCache allKeys]]];


    return ([channelsSet count] ? [self.stateCache dictionaryWithValuesForKeys:[channelsSet allObjects]] : nil);
}

- (void)purgeStateForChannel:(PNChannel *)channel {

    if (channel) {

        [self.stateCache removeObjectForKey:channel.name];
    }
}

- (void)purgeStateForChannels:(NSArray *)channels {

    if (channels) {

        [self.stateCache removeObjectsForKeys:[channels valueForKey:@"name"]];
    }
}

- (void)purgeAllState {

    [self.stateCache removeAllObjects];
}


#pragma mark - Data Synchronization observers

- (PNObject *)objectWithIdentifier:(NSString *)objectIdentifier {

    return [self.objects valueForKey:objectIdentifier];
}

- (void)storeSynchronizationEvent:(PNObjectSynchronizationEvent *)event {

    // Check whether already created storage for set of events
    if (![self.objectUpdates objectForKey:event.objectIdentifier]) {

        [self.objectUpdates setValue:[NSMutableDictionary dictionary] forKey:event.objectIdentifier];
    }

    NSMutableArray *changeEvents = [[self.objectUpdates valueForKey:event.objectIdentifier] valueForKey:event.eventTransactionIdentifier];
    if (!changeEvents) {

        changeEvents = [NSMutableArray array];
        [[self.objectUpdates valueForKey:event.objectIdentifier] setValue:changeEvents forKey:event.eventTransactionIdentifier];

    }

    [changeEvents addObject:event];
}

- (PNObject *)commitSynchronizationEvent:(PNObjectSynchronizationEvent *)event {

    PNObject *object = [self.objects valueForKey:event.objectIdentifier];
    if ([self.objectUpdates objectForKey:event.objectIdentifier]) {
        
        NSMutableDictionary *storedObjectData = (object.data ? object.data : [NSMutableDictionary dictionary]);
        
        void(^processEventsBlock)(NSMutableDictionary *, PNObjectSynchronizationEvent *) = ^(NSMutableDictionary *objectData,
                                                                                             PNObjectSynchronizationEvent *event) {
            
            PNObjectSynchronizationEventType eventType = event.type;
            
            // Checking whether changed/retrieved only piece of information
            if (event.changeLocation != nil) {
                
                if (eventType == PNObjectInitEvent || eventType == PNObjectUpdateEvent) {
                    
                    if (event.changedData) {
                        
                        if (![event.changedData isKindOfClass:[NSDictionary class]] || ![objectData valueForKeyPath:event.changeLocation]) {
                            
                            [objectData setValue:event.changedData forKeyPath:event.changeLocation createIntermediateEntries:YES];
                        }
                        else if ([objectData valueForKeyPath:event.changeLocation] && [event.changedData isKindOfClass:[NSDictionary class]]) {
                            
                            if ([[objectData valueForKeyPath:event.changeLocation] isKindOfClass:[NSMutableDictionary class]]) {
                                
                                [(NSMutableDictionary *)[objectData valueForKeyPath:event.changeLocation] mergeWithDictionary:event.changedData];
                            }
                        }
                    }
                }
                else if (eventType == PNObjectDeleteEvent) {
                    
                    [objectData removeObjectForKeyPath:event.changeLocation];
                }
            }
            else {
                
                if (eventType == PNObjectInitEvent || eventType == PNObjectUpdateEvent) {
                    
                    [objectData mergeWithDictionary:event.changedData];
                }
                else if (eventType == PNObjectDeleteEvent) {
                    
                    [objectData removeAllObjects];
                }
            }
        };
        
        __block NSString *changeDate = nil;
        // Check whether initialization transaction complete event arrived.
        if ([event.eventTransactionIdentifier isEqualToString:[PNObjectSynchronizationEvent initializationTransactionIdentifier]]) {
            
            NSArray *events = [[self.objectUpdates valueForKey:event.objectIdentifier] valueForKey:event.eventTransactionIdentifier];
            [events enumerateObjectsUsingBlock:^(PNObjectSynchronizationEvent *event, NSUInteger eventIdx,
                                                 BOOL *eventEnumeratorStop) {
                
                processEventsBlock(storedObjectData, event);
            }];
            changeDate = ((PNObjectSynchronizationEvent *)[events lastObject]).changeDate;
            [[self.objectUpdates valueForKey:event.objectIdentifier] removeObjectForKey:event.eventTransactionIdentifier];
        }
        
        // Checking whether additional transaction information available or not.
        if ([[self.objectUpdates valueForKey:event.objectIdentifier] count]) {
            
            NSMutableDictionary *transactions = [self.objectUpdates valueForKey:event.objectIdentifier];
            NSMutableDictionary *completedTransactions = [NSMutableDictionary dictionaryWithCapacity:[transactions count]];
            [transactions enumerateKeysAndObjectsUsingBlock:^(NSString *transactionIdentifier, NSMutableArray *transactionsList,
                                                              BOOL *transactionsEnumeratorStop) {
                
                PNObjectSynchronizationEvent *lastEvent = [transactionsList lastObject];
                if (lastEvent && lastEvent.type == PNObjectCompleteEvent) {
                    
                    [completedTransactions setValue:lastEvent.changeDate forKeyPath:lastEvent.eventTransactionIdentifier];
                }
            }];
            
            NSArray *sortedTransactions = [completedTransactions keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                
                return [obj1 compare:obj2];
            }];
            
            if ([sortedTransactions count]) {
                
                [sortedTransactions enumerateObjectsUsingBlock:^(NSString *transactionIdentifier, NSUInteger transactionIdentifierIdx,
                                                                 BOOL *transactionIdentifierEnumeratorStop) {
                    
                    NSArray *events = [[self.objectUpdates valueForKey:event.objectIdentifier] valueForKey:transactionIdentifier];
                    [events enumerateObjectsUsingBlock:^(PNObjectSynchronizationEvent *storedEvent, NSUInteger eventIdx,
                                                         BOOL *eventEnumeratorStop) {
                        
                        processEventsBlock(storedObjectData, storedEvent);
                    }];
                    changeDate = ((PNObjectSynchronizationEvent *)[events lastObject]).changeDate;
                    [[self.objectUpdates valueForKey:event.objectIdentifier] removeObjectForKey:transactionIdentifier];
                }];
            }
        }


        if (!object) {

            object = [PNObject objectWithIdentifier:event.objectIdentifier andData:storedObjectData];
            object.updateDate = [PNDate dateWithToken:PNNumberFromUnsignedLongLongString(changeDate)];
            [self.objects setValue:object forKey:event.objectIdentifier];
        }
        if ([[self.objectUpdates valueForKey:event.objectIdentifier] count] == 0) {
            
            [self.objectUpdates removeObjectForKey:event.objectIdentifier];
        }
    }


    return object;
}

- (void)purgeAllObjects {

    [self.objectUpdates removeAllObjects];
    [self.objects removeAllObjects];
}

#pragma mark -


@end
