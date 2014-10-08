//
//  BDFMyProfile.h
//  Buddyfied
//
//  Created by Tom Gilbert on 10/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BDFBuddyProfile.h"

@class BDFYears;

@interface BDFMyProfile : BDFBuddyProfile

@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSSet *years;
@end

@interface BDFMyProfile (CoreDataGeneratedAccessors)

- (void)addYearsObject:(BDFYears *)value;
- (void)removeYearsObject:(BDFYears *)value;
- (void)addYears:(NSSet *)values;
- (void)removeYears:(NSSet *)values;

@end
