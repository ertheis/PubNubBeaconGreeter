//
//  PNError+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 01/08/13.
//
//

#import "PNError.h"


#pragma mark Protected interface methods

@interface PNError (Protected)

// Stores reference on associated object with which
// error is occurred
@property (nonatomic, strong) id associatedObject;


#pragma mark - Instance methods

/**
 Replace existing associated object with new one. This is exclusion method for rare cases.

 @param object
 Reference on object which should be stored instead of old one.
 */
- (void)replaceAssociatedObjectWith:(id)object;

#pragma mark -


@end
