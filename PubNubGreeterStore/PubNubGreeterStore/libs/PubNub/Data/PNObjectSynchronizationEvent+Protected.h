//
//  PNObjectSynchronizationEvent+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/13/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectSynchronizationEvent.h"


#pragma mark Static

// This enum represents all data keys which is used in
// object synchronization event response dictionary from JSON
struct PNObjectSynchronizationEventDataKeysStruct {

    /**
     Stores synchronization action type.
     */
    __unsafe_unretained NSString *action;

    /**
     Stores synchronization transaction status
     */
    __unsafe_unretained NSString *status;

    /**
     Stores synchronization group transaction ID
     */
    __unsafe_unretained NSString *transactionIdentifier;

    /**
     Stores synchronization event triggering time.
     */
    __unsafe_unretained NSString *timeToken;

    /**
     Stores location where new value has been specified.
     */
    __unsafe_unretained NSString *location;

    /**
     Stores updated value which should be applied at path specified in \c location field..
     */
    __unsafe_unretained NSString *value;
};

extern struct PNObjectSynchronizationEventDataKeysStruct PNObjectSynchronizationEventDataKeys;


#pragma mark - Private interface declaration

@interface PNObjectSynchronizationEvent ()


#pragma mark - Properties

@property (nonatomic, assign) PNObjectSynchronizationEventType type;
@property (nonatomic, copy) NSString *eventTransactionIdentifier;
@property (nonatomic, copy) NSString *objectIdentifier;
@property (nonatomic, copy) NSString *changeLocation;
@property (nonatomic, copy) NSString *changeDate;
@property (nonatomic, strong) id changedData;


#pragma mark - Class methods

/**
 Construct synchronization event for concrete remote object.

 @param type
 One of \b PNObjectSynchronizationEventType fields which specify concrete change event action which should be
 performed on local copy of the object.

 @param objectIdentifier
 Reference on remote object identifier for which this event has been generated.

 @param changeLocation
 Reference on location at which change should be preformed.

 @param transactionIdentifier
 Unique identifier for set of events which should be treated at the end as single transaction.

 @param changeDate
 Reference on date when this change has been generated.

 @param changedData
 \a id object which store reference on data which should be applied using \c changeLocation path and \c type for
 concrete action.

 @return Ready to use \b PNObjectSynchronizationEvent instance.
 */
+ (PNObjectSynchronizationEvent *)synchronizationEvent:(PNObjectSynchronizationEventType)type forObject:(NSString *)objectIdentifier
                                 transactionIdentifier:(NSString *)transactionIdentifier atLocation:(NSString *)changeLocation
                                            changeDate:(NSString *)changeDate andData:(id)changedData;

/**
 Create synchronization instance from event which arrived from server on one of observation channels.

 @param objectIdentifier
 Reference on remote object identifier for which this event has been generated.

 @param changeLocation
 Reference on location at which change should be preformed.

 @param event
 Reference on event object which arrived from \b PubNub cloud.
 */
+ (PNObjectSynchronizationEvent *)synchronizationEventForObject:(NSString *)objectIdentifier atPath:(NSString *)changeLocation
                                                 dromDictionary:(NSDictionary *)event;

/**
 Create "completion" eevent basing on last event information.
 
 @param event
 Event from which required information should be pulled out.
 
 @return Ready to use completion event.
 */
+ (PNObjectSynchronizationEvent *)synchronizationCompletionFromEvent:(PNObjectSynchronizationEvent *)event;

/**
 Verify whether provided payload should be treated as synchronization event or not.

 @param eventPayload
 Dictionary against which check should be performed.

 @return \c YES in case if this is payload for remote object synchronization.
 */
+ (BOOL)isSynchronizationEvent:(NSDictionary *)eventPayload;

/**
 Retrieve reference on \b 'initialization' transaction which is issued when object is fetched from \b PubNub cloud.
 
 @return Transaction identifier.
 */
+ (NSString *)initializationTransactionIdentifier;


#pragma mark - Instance methods

/**
 Initialize synchronization event for concrete remote object.

 @param type
 One of \b PNObjectSynchronizationEventType fields which specify concrete change event action which should be
 performed on local copy of the object.

 @param objectIdentifier
 Reference on remote object identifier for which this event has been generated.

 @param changeLocation
 Reference on location at which change should be preformed.

 @param transactionIdentifier
 Unique identifier for set of events which should be treated at the end as single transaction.

 @param changeDate
 Reference on date when this change has been generated.

 @param changedData
 \a id object which store reference on data which should be applied using \c changeLocation path and \c type for
 concrete action.

 @return Ready to use \b PNObjectSynchronizationEvent instance.
 */
- (id)initWithEvent:(PNObjectSynchronizationEventType)type forObject:(NSString *)objectIdentifier
transactionIdentifier:(NSString *)transactionIdentifier atLocation:(NSString *)changeLocation
           changeDate:(NSString *)changeDate andData:(id)changedData;


@end
