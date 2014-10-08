//
//  BDFBuddyProfile+Calculated.h
//  Buddyfied
//
//  Created by Tom Gilbert on 14/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFBuddyProfile.h"

@interface BDFBuddyProfile (Calculated)

-(NSDictionary*) dictionaryForTransmission;
-(NSString*) flattenedAttributeIDsForSet:(NSString*)propertyName;

@end
