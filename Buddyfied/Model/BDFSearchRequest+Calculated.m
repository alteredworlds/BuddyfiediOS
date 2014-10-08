//
//  BDFSearchRequest+Calculated.m
//  Buddyfied
//
//  Created by Tom Gilbert on 27/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFSearchRequest+Calculated.h"
#import "BDFPlatform.h"

@implementation BDFSearchRequest (Calculated)

-(BOOL)anyActiveSearchCriteria
{
    BOOL retVal =
    (self.platform.count > 0) ||
    (self.playing.count > 0)  ||
    (self.gameplay.count > 0) ||
    (self.country.count > 0)  ||
    (self.language.count > 0)  ||
    (self.skill.count > 0)  ||
    (self.time.count > 0) ||
    (self.age.count > 0) ||
    (self.voice.count > 0);
    return retVal;
}

@end
