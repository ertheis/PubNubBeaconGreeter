//
//  NSMutableDictionary+PNAdditions.h
//  pubnub
//
//  Created by Sergey Mamontov on 7/13/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public category interface declaration

@interface NSMutableDictionary (PNAdditions)


#pragma mark - Instance methods

/**
 Set concrete value at specified key-path and create intermediate entries if will be requested.

 @param value
 Value which should be stored at specified key-path.

 @param keyPath
 Full key-path under which value should be stored.

 @param shouldCreateIntermediateEntries
 If set to \c YES all non-existing intermediate entries will be created.
 */
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath createIntermediateEntries:(BOOL)shouldCreateIntermediateEntries;

/**
 Remove values stored at specified key-path.

 @param keyPath
 Key-path from which value should be removed.
 */
- (void)removeObjectForKeyPath:(NSString *)keyPath;

/**
 Iterate over the list of entries and update them with values from second dictionary.

 @param dictionary
 Reference on dictionary which should be merged with receiver.
 */
- (void)mergeWithDictionary:(NSMutableDictionary *)dictionary;

#pragma mark -


@end
