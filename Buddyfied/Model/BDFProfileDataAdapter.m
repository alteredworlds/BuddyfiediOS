//
//  BDFProfileDataAdapter.m
//  Buddyfied
//
//  Created by Tom Gilbert on 03/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFProfileDataAdapter.h"

@implementation BDFProfileDataAdapter

-(instancetype)init
{
    if (self = [super init])
    {
        [self.propertyNames addObject:@"comments"];
        [self.entityNames addObject:@"Comments"];
        //
        // age no longer needs to be flattened
        NSUInteger idx = [self.flattenPropertyNames indexOfObject:@"age"];
        if (NSNotFound != idx)
        {
            [self.flattenPropertyNames removeObjectAtIndex:idx];
        }
    }
    return self;
}

-(NSUInteger) commentRow
{
    return [self.entityNames indexOfObject:@"Comments"];
}

@end
