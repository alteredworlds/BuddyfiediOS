//
//  BDFBuddyProfile+Helpers.m
//  Buddyfied
//
//  Created by Tom Gilbert on 27/05/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFBuddyProfile+Helpers.h"

@implementation BDFBuddyProfile (Helpers)

- (void) clear
{
    // remove all linked attributes from this BuddyProfile
    //
    [[self mutableSetValueForKey:@"age"] removeAllObjects];
    [[self mutableSetValueForKey:@"country"] removeAllObjects];
    [[self mutableSetValueForKey:@"gameplay"] removeAllObjects];
    [[self mutableSetValueForKey:@"language"] removeAllObjects];
    [[self mutableSetValueForKey:@"platform"] removeAllObjects];
    [[self mutableSetValueForKey:@"playing"] removeAllObjects];
    [[self mutableSetValueForKey:@"skill"] removeAllObjects];
    [[self mutableSetValueForKey:@"time"] removeAllObjects];
    [[self mutableSetValueForKey:@"voice"] removeAllObjects];
}

@end
