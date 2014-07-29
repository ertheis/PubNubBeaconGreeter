//
//  PNObjectFetchInformation+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/13/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectFetchInformation.h"


#pragma mark Private interface declaration

@interface PNObjectFetchInformation ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *partialObjectDataPath;
@property (nonatomic, copy) NSString *dataNextPageToken;
@property (nonatomic, copy) NSString *objectIdentifier;
@property (nonatomic, copy) NSString *snapshotDate;


#pragma mark - Class methods

/**
 Construct instance which will represent information which will be used to fetch remote object.

 @param objectInformation
 Reference on remote object identifier in \b PubNub cloud.

 @param partialObjectDataPath
 Sub-path inside remote object data tree.

 @param snapshotDate
 Reference on object snapshot actual for specified date.

 @param dataNextPageToken
 Reference on token which should be used during remote object fetch to get next portion of object data from cloud.

 @return Ready to use \b PNObjectFetchInformation instance.
 */
+ (PNObjectFetchInformation *)objectFetchInformation:(NSString *)objectInformation path:(NSString *)partialObjectDataPath
                                        snapshotDate:(NSString *)snapshotDate andDataNextPageToken:(NSString *)dataNextPageToken;


#pragma mark - Instance methods

/**
 Initiate object which will represent information which will be used to fetch remote object.

 @param objectInformation
 Reference on remote object identifier in \b PubNub cloud.

 @param partialObjectDataPath
 Sub-path inside remote object data tree.

 @param snapshotDate
 Reference on object snapshot actual for specified date.

 @param dataNextPageToken
 Reference on token which should be used during remote object fetch to get next portion of object data from cloud.

 @return Ready to use \b PNObjectFetchInformation instance.
 */
- (id)initFetchInformation:(NSString *)objectInformation path:(NSString *)partialObjectDataPath
              snapshotDate:(NSString *)snapshotDate andDataNextPageToken:(NSString *)dataNextPageToken;


@end
