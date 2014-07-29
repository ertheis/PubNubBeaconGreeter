//
//  NSArray+PNAdditions.h
//  pubnub
//
//  Created by Sergey Mamontov on 05/14/13.
//
//

#import <Foundation/Foundation.h>


@interface NSArray (PNAdditions)


#pragma mark Class methods

+ (NSArray *)arrayWithVarietyList:(va_list)list;

/**
 Construct from receiver mutable array where every collection inside is mutable as well.

 @return Mutable array with mutable collections inside.
 */
- (NSMutableArray *)mutableContent;

#pragma mark -


@end
