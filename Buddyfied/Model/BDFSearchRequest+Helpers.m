//
//  BDFSearchRequest+Helpers.m
//  Buddyfied
//
//  Created by Tom Gilbert on 27/05/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFSearchRequest+Helpers.h"
#import "BDFBuddyProfile+Helpers.h"
#import "BDFBuddy+Helpers.h"

@implementation BDFSearchRequest (Helpers)

- (void) clear
{
    [super clear];
    //
    // all Buddies are result of the single search request - so if the request changes
    //  we need to get rid of all the Buddies...
    [BDFBuddy clearAllFromManagedObjectContext:self.managedObjectContext];
}


@end
