//
//  PNObjectAccessRightsCollection+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/18/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObjectAccessRightsCollection.h"


#pragma mark Class forward

@class PNAccessRightsCollection;


#pragma mark - Private interface declaration

@interface PNObjectAccessRightsCollection ()


#pragma mark - Properties

/**
 Stores application identifier key.
 */
@property (nonatomic, copy) NSString *applicationKey;

/**
 Stores dictionary of channel name - \b PNObjectAccessRightsInformation instances pairs which represents access rights for
 cloud \a 'object' access level.
 */
@property (nonatomic, strong) NSMutableDictionary *objectsAccessRightsInformation;

/**
 Stores dictionary of client authorization key - \b PNObjectAccessRightsInformation instances which represents access
 rights for \a 'user' access level.
 */
@property (nonatomic, strong) NSMutableDictionary *clientsAccessRightsInformation;


#pragma mark - Class methods

/**
 Construct access rights collection instance for cloud objuect from existing collection for the channels.
 
 @param channelAccessRightsInformation
 Original access rights information object.
 
 @return Ready to use instance which hold information about access rights to cloud object.
 */
+ (PNObjectAccessRightsCollection *)objectAccessRightsFrom:(PNAccessRightsCollection *)channelAccessRightsInformation;


#pragma mark - Instance methods
/**
 Initiate access rights collection instance for cloud objuect from existing collection for the channels.
 
 @param channelAccessRightsInformation
 Original access rights information object.
 
 @return Ready to use instance which hold information about access rights to cloud object.
 */
- (id)initWithRightsFrom:(PNAccessRightsCollection *)channelAccessRightsInformation;


#pragma mark - Misc methods

/**
 Perform object convertion from \b PNAccessRightsCollection to \b PNObjectAccessRightsCollection and store it in provided storage.
 
 @param channelsAccessRightsInformation
 Reference on original set of \b PNAccessRightsCollection which should be processed.
 
 @param objectsAccessRightsInformationStorage
 Reference on target storage in which \b PNObjectAccessRightsCollection instances should be stored.
 */
- (void)storeConvertedChannelAccessRightsInformation:(NSDictionary *)channelsAccessRightsInformation
                                                  in:(NSMutableDictionary *)objectsAccessRightsInformationStorage;

/**
 Allow to copy \a 'allowing' access rights from \a source access rights information into \a target access rights
 information.
 
 @param sourceAccessRightsInformation
 \b PNObjectAccessRightsInformation instance from which \a 'allowing' access rights should be copied.
 
 @param targetAccessRightsInformation
 \b PNObjectAccessRightsInformation instance into which \a 'allowing' access rights should be copied.
 
 @note This method used to override access rights information of lower layer with information from upper layer in
 case if they provide \a 'allowing' access rights at places where \c targetAccessRightsInformation doesn't allow them.
 */
- (void)populateAccessRightsFrom:(PNObjectAccessRightsInformation *)sourceAccessRightsInformation
                              to:(PNObjectAccessRightsInformation *)targetAccessRightsInformation;

#pragma mark -


@end
