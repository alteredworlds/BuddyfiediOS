//
//  BDFPlayerAttribute+Calculated.m
//  Buddyfied
//
//  Created by Tom Gilbert on 07/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFPlayerAttribute+Calculated.h"

@implementation BDFPlayerAttribute (Calculated)

- (NSString *)sectionNameForName
{
    NSInteger idx = [[UILocalizedIndexedCollation currentCollation] sectionForObject:self collationStringSelector:@selector(name)];
    NSString *collRet = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:idx];
    
    return collRet;
}

@end
