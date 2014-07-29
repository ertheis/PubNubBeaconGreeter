//
//  PNObject+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/11/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObject.h"


#pragma mark Private interface declaration

@interface PNObject () <NSCoding>


#pragma mark - Properties

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) PNDate *updateDate;

/**
 Dictionary which represent current object information in \b PubNub cloud. This dictionary initially populated by one
 of the clients and further updated by real-time events.
 */
@property (nonatomic, strong) NSMutableDictionary *data;


#pragma mark - Class methods

/**
 Construct representing instance for object in \b PubNub cloud.

 @param identifier
 String identifier which is used by \b PubNub cloud to store concrete object.

 @param objectData
 Initial object data which should be stored locally or updated in \b PubNub cloud.

 @return Ready to use instance.
 */
+ (PNObject *)objectWithIdentifier:(NSString *)identifier andData:(NSDictionary *)objectData;


#pragma mark - Instance methods

/**
 Initiate representing instance for object in \b PubNub cloud.

 @param identifier
 String identifier which is used by \b PubNub cloud to store concrete object.

 @param objectData
 Initial object data which should be stored locally or updated in \b PubNub cloud.

 @return Ready to use instance.
 */
- (id)initWithIdentifier:(NSString *)identifier andData:(NSDictionary *)objectData;

/**
 Update value stored at specified key-path.

 @param updatedValue
 Reference on object which should be stored locally or updated in \b PubNub cloud.

 @param keyPath
 Reference on key-path under which object should be stored.
 */
- (void)updateValue:(id)updatedValue atKeyPath:(NSString *)keyPath;

#pragma mark -


@end
