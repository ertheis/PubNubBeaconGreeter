//
//  NSMutableDictionary+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 7/13/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "NSMutableDictionary+PNAdditions.h"


#pragma mark Public category interface declaration

@implementation NSMutableDictionary (PNAdditions)


#pragma mark - Instance methods

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath createIntermediateEntries:(BOOL)shouldCreateIntermediateEntries {

    if (!shouldCreateIntermediateEntries) {

        [self setValue:value forKeyPath:keyPath];
    }
    else {

        __block NSMutableDictionary *currentLevel = self;
        NSArray *pathComponents = [keyPath componentsSeparatedByString:@"."];
        [pathComponents enumerateObjectsUsingBlock:^(NSString *path, NSUInteger pathIdx, BOOL *pathEnumeratorStop) {

            if (pathIdx != ([pathComponents count] - 1)) {

                if (![currentLevel objectForKey:path]) {

                    [currentLevel setValue:[NSMutableDictionary dictionary] forKey:path];
                }

                currentLevel = [currentLevel valueForKey:path];
            }
            else {

                [currentLevel setValue:value forKey:path];
            }
        }];
    }
}

- (void)removeObjectForKeyPath:(NSString *)keyPath {

    if ([self valueForKeyPath:keyPath]) {

        NSArray *pathComponents = [keyPath componentsSeparatedByString:@"."];
        __block NSMutableDictionary *parentLevel = nil;
        __block NSMutableDictionary *currentLevel = self;
        if ([pathComponents count] == 1) {

            [currentLevel removeObjectForKey:[pathComponents lastObject]];
            if (![currentLevel count]) {

                [self removeAllObjects];
            }
        }
        else {

            [pathComponents enumerateObjectsUsingBlock:^(NSString *path, NSUInteger pathIdx, BOOL *pathEnumeratorStop) {

                if (pathIdx != ([pathComponents count] - 2)) {

                    parentLevel = currentLevel;
                    currentLevel = [currentLevel valueForKey:path];
                }
                else {

                    [currentLevel removeObjectForKey:path];
                    if (![currentLevel count]) {

                        [parentLevel removeAllObjects];
                    }
                }
            }];
        }
    }
}

- (void)mergeWithDictionary:(NSMutableDictionary *)dictionary {

    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *entryKey, id entryValue, BOOL *entryEnumeratorStop) {

        if ([self valueForKey:entryKey] && [entryValue isKindOfClass:[NSDictionary class]]) {

            [(NSMutableDictionary *)[self valueForKey:entryKey] mergeWithDictionary:entryValue];
        }
        else {

            [self setValue:entryValue forKey:entryKey];
        }
    }];
}

#pragma mark -


@end
