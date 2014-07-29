//
//  PNObjectModificationInformation+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectModificationInformation.h"


#pragma mark Private interface declaration

@interface PNObjectModificationInformation ()


#pragma mark - Properties

@property (nonatomic, assign) PNObjectModificationType type;
@property (nonatomic, copy) NSString *objectIdentifier;
@property (nonatomic, copy) NSString *modificationLocation;
@property (nonatomic, strong) id data;


#pragma mark - Class methods

/**
 Construct object modification information instance which can be used by user and client to find out some
 specification on processed modification.

 @param type
 Stores reference on one of \b PNObjectModificationType fields which describe concrete modification action.

 @param objectIdentifier
 Reference on unique remote object identifier in \b PubNub cloud.

 @param modificationLocation
 Reference on path inside object's data structure for modification.

 @param data
 Reference on data which should be used for information modification.

 @return Reference on \b PNObjectModificationInformation ready to use.
 */
+ (PNObjectModificationInformation *)modificationInformation:(PNObjectModificationType)type forObject:(NSString *)objectIdentifier
                                                  atLocation:(NSString *)modificationLocation andData:(id)data;


#pragma mark - Instance methods

/**
 Initiate object modification information instance which can be used by user and client to find out some
 specification on processed modification.

 @param type
 Stores reference on one of \b PNObjectModificationType fields which describe concrete modification action.

 @param objectIdentifier
 Reference on unique remote object identifier in \b PubNub cloud.

 @param modificationLocation
 Reference on path inside object's data structure for modification.

 @param data
 Reference on data which should be used for information modification.

 @return Reference on \b PNObjectModificationInformation ready to use.
 */
- (id)initModification:(PNObjectModificationType)type forObject:(NSString *)objectIdentifier atLocation:(NSString *)modificationLocation
               andData:(id)data;


@end
