//
//  BDFFlatBuddyProfile.h
//  Buddyfied
//
//  Created by Tom Gilbert on 10/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BDFFlatBuddyProfile : NSManagedObject

@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * gameplay;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * platform;
@property (nonatomic, retain) NSString * playing;
@property (nonatomic, retain) NSString * skill;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSString * voice;
@property (nonatomic, retain) NSString * years;

@end
