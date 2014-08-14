//
//  PNSynchronizationChannel+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/14/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNSynchronizationChannel.h"


#pragma mark Private interface declaration

@interface PNSynchronizationChannel ()


#pragma mark - Properties

/**
 Stores reference on original object identifier for which this synchronization channel has been created.
 */
@property (nonatomic, copy) NSString *objectIdentifier;

/**
 Stores reference on object partial data path which is part of the name.
 */
@property (nonatomic, copy) NSString *partialObjectDataPath;

@property (nonatomic, assign, getter = isObjectSynchronizationChannel)BOOL objectSyncronizationChannel;


#pragma mark - Class methods

/**
 Construct list of channels for real-time events observation on local object copy change from cloud.
 
 @param objectIdentifiers
 Set of \a NSString instances for which \b PNSynchronizationChannel should be created.
 
 @return List of special channels which represent cloud object data channel.
 */
+ (NSArray *)channelsForObjects:(NSArray *)objectIdentifiers;

/**
 Construct list of channels for real-time events observation on local object copy change from cloud.
 
 @param objectIdentifier
 Reference on identifier which represent remote object in \b PubNub cloud.
 
 @return List of special channels which represent cloud object data channel.
 */
+ (PNSynchronizationChannel *)channelForObject:(NSString *)objectIdentifier;

/**
 Construct channel for real-time events observation on local object copy change from cloud.

 @param objectIdentifier
 Reference on identifier which represent remote object in \b PubNub cloud.

 @param partialObjectDataPath
 Reference on sub-path inside remote object (this allow to observe changes only on piece of remote object).

 @return Required set of channels for synchronization and synchronization transactions observation.
 */
+ (id)channelForObject:(NSString *)objectIdentifier dataPath:(NSString *)partialObjectDataPath;

/**
 Construct channel for real-time events observation on local object copy change from cloud.

 @param objectIdentifier
 Reference on identifier which represent remote object in \b PubNub cloud.

 @param partialObjectDataPath
 Reference on sub-path inside remote object (this allow to observe changes only on piece of remote object).

 @return Required set of channels for synchronization and synchronization transactions observation.
 */
+ (NSArray *)channelsForObject:(NSString *)objectIdentifier dataPath:(NSString *)partialObjectDataPath;

/**
 Check whether specified name correspond to one of data synchronization channels or not.
 
 @param channelName
 Name of the channels against which check should be done.
 
 @return \c YES in case if this channel is used for Data Synchronization feature.
 */
+ (BOOL)isObjectSynchronizationChannel:(NSString *)channelName;

#pragma mark -


@end
