//
//  PNSynchronizationChannel.m
//  pubnub
//
//  Created by Sergey Mamontov on 7/14/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNSynchronizationChannel+Protected.h"
#import "PNObjectSynchronizationEvent.h"


#pragma mark Public interface declaration

@implementation PNSynchronizationChannel


#pragma mark - Class methods

+ (NSArray *)channelsForObjects:(NSArray *)objectIdentifiers {
    
    NSMutableArray *channels = [NSMutableArray arrayWithCapacity:[objectIdentifiers count]];
    [objectIdentifiers enumerateObjectsUsingBlock:^(NSString *objectIdentifier, NSUInteger objectIdentifierIdx,
                                                    BOOL *objectIdentifierEnumeratorStop) {

        [channels addObject:[self channelForObject:objectIdentifier]];
    }];
    
    
    return channels;
}

+ (PNSynchronizationChannel *)channelForObject:(NSString *)objectIdentifier {
    
    return [self channelForObject:objectIdentifier dataPath:nil];
}

+ (id)channelForObject:(NSString *)objectIdentifier dataPath:(NSString *)partialObjectDataPath {
    
    NSString *channelName = objectIdentifier;
    if ([objectIdentifier hasSuffix:@".*"]) {
        
        objectIdentifier = [objectIdentifier stringByReplacingOccurrencesOfString:@".*" withString:@""];
    }
    if (![channelName hasPrefix:@"pn_ds_"] && ![channelName hasPrefix:@"pn_dstr_"]) {
        
        channelName = [NSString stringWithFormat:@"pn_ds_%@", objectIdentifier];
    }
    else {
        
        objectIdentifier = [[objectIdentifier stringByReplacingOccurrencesOfString:@"pn_ds_" withString:@""]
                            stringByReplacingOccurrencesOfString:@"pn_dstr_" withString:@""];
    }

    PNSynchronizationChannel *channel = [super channelWithName:channelName shouldObservePresence:NO];
    channel.objectIdentifier = objectIdentifier;
    channel.partialObjectDataPath = partialObjectDataPath;
    channel.objectSyncronizationChannel = YES;


    return channel;
}

+ (NSArray *)channelsForObject:(NSString *)objectIdentifier dataPath:(NSString *)partialObjectDataPath {
    
    NSString *wildCardChannelName = [NSString stringWithFormat:@"pn_ds_%@.*", objectIdentifier];
    NSString *transactionChannelName = [NSString stringWithFormat:@"pn_dstr_%@", objectIdentifier];


    return @[[PNSynchronizationChannel channelForObject:objectIdentifier  dataPath:partialObjectDataPath],
             [PNSynchronizationChannel channelForObject:wildCardChannelName dataPath:([partialObjectDataPath length] > 0 ?
                                                                                      [NSString stringWithFormat:@"%@.*", partialObjectDataPath] :
                                                                                      @"*")],
             [PNSynchronizationChannel channelForObject:transactionChannelName dataPath:partialObjectDataPath]];
}

+ (BOOL)isObjectSynchronizationChannel:(NSString *)channelName {
    
    return ([channelName hasPrefix:@"pn_ds_"] || [channelName hasPrefix:@"pn_dstr_"]);
}

#pragma mark -


@end
