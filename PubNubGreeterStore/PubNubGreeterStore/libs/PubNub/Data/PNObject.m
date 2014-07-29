//
//  PNObject.m
//  pubnub
//
//  Created by Sergey Mamontov on 7/11/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNObject+Protected.h"
#import "NSDictionary+PNAdditions.h"
#import "PNDate.h"


#pragma mark Public interface implementation

@implementation PNObject


#pragma mark - Class methods

+ (PNObject *)objectWithIdentifier:(NSString *)identifier andData:(NSDictionary *)objectData {

    return [[self alloc] initWithIdentifier:identifier andData:objectData];
}


#pragma mark - Instance methods

- (id)initWithIdentifier:(NSString *)identifier andData:(NSDictionary *)objectData {

    // Check whether initialization successful or not.
    if ((self = [super init])) {

        self.identifier = identifier;
        self.updateDate = [PNDate dateWithDate:[NSDate date]];
        self.data = (objectData ? [objectData mutableContent] : [NSMutableDictionary dictionary]);
    }


    return self;
}

- (void)updateValue:(id)updatedValue atKeyPath:(NSString *)keyPath {

    if ([keyPath length] && updatedValue) {

        __block id targetValueStorage = self.data;
        NSArray *keyPathComponents = [keyPath componentsSeparatedByString:@"."];
        [keyPathComponents enumerateObjectsUsingBlock:^(NSString *key, NSUInteger keyIdx, BOOL *keyEnumeratorStop) {

            if (keyIdx == ([keyPathComponents count] - 1)) {

                id targetValue = ([updatedValue respondsToSelector:@selector(count)] ? [updatedValue mutableContent] : updatedValue);
                [targetValueStorage setValue:targetValue forKey:key];
            }
            else {

                if (![targetValueStorage valueForKey:key]) {

                    [targetValueStorage setValue:[NSMutableDictionary dictionary] forKey:key];

                }
                targetValueStorage = [targetValueStorage valueForKey:key];
            }
        }];
    }
}

- (NSString *)description {

    return [NSString stringWithFormat:@"%@(%p) %@ object data updated at %@:\n%@", NSStringFromClass([self class]),
                    self, self.identifier, self.updateDate.date, self.data];
}


#pragma mark - NSDictionary calls forward

- (NSUInteger)count {

    return [self.data count];
}

- (id)objectForKey:(id)aKey {

    return [self.data objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator {

    return [self.data keyEnumerator];
}

- (NSArray *)allKeys {

    return [self.data allKeys];
}

- (NSArray *)allKeysForObject:(id)anObject {

    return [self.data allKeysForObject:anObject];
}

- (NSArray *)allValues {

    return [self.data allValues];
}

- (NSEnumerator *)objectEnumerator {

    return [self.data objectEnumerator];
}

- (NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker {

    return [self.data objectsForKeys:keys notFoundMarker:marker];
}

- (NSArray *)keysSortedByValueUsingSelector:(SEL)comparator {

    return [self.data keysSortedByValueUsingSelector:comparator];
}

- (void)getObjects:(id __unsafe_unretained [])objects andKeys:(id __unsafe_unretained [])keys {

    return [self.data getObjects:objects andKeys:keys];
}

- (id)objectForKeyedSubscript:(id)key {

    return [self.data objectForKeyedSubscript:key];
}

#if NS_BLOCKS_AVAILABLE
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block {

    [self.data enumerateKeysAndObjectsUsingBlock:block];
}

- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, id obj, BOOL *stop))block {

    [self.data enumerateKeysAndObjectsWithOptions:opts usingBlock:block];
}

- (NSArray *)keysSortedByValueUsingComparator:(NSComparator)cmptr {

    return [self.data keysSortedByValueUsingComparator:cmptr];
}

- (NSArray *)keysSortedByValueWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr {

    return [self.data keysSortedByValueWithOptions:opts usingComparator:cmptr];
}

- (NSSet *)keysOfEntriesPassingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate {

    return [self.data keysOfEntriesPassingTest:predicate];
}

- (NSSet *)keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate {

    return [self.data keysOfEntriesWithOptions:opts passingTest:predicate];
}
#endif

#pragma mark -


@end
