//
//  BDFMyProfile+Calculated.h
//  Buddyfied
//
//  Created by Tom Gilbert on 07/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFMyProfile.h"

@interface BDFMyProfile (Calculated)

-(NSDictionary*) dictionaryForTransmission;
+ (NSDictionary*) diffsDictionaryForTransmission:(NSDictionary*)dictionaryForTransmissionBefore
                                        andAfter:(NSDictionary*)dictionaryForTransmissionAfter;

@end
