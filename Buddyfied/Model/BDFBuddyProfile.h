//
//  BDFBuddyProfile.h
//  Buddyfied
//
//  Created by Tom Gilbert on 10/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BDFAge, BDFCountry, BDFGameplay, BDFLanguage, BDFPlatform, BDFPlaying, BDFSkill, BDFTime, BDFVoice;

@interface BDFBuddyProfile : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSSet *age;
@property (nonatomic, retain) NSSet *country;
@property (nonatomic, retain) NSSet *gameplay;
@property (nonatomic, retain) NSSet *language;
@property (nonatomic, retain) NSSet *platform;
@property (nonatomic, retain) NSSet *playing;
@property (nonatomic, retain) NSSet *skill;
@property (nonatomic, retain) NSSet *time;
@property (nonatomic, retain) NSSet *voice;
@end

@interface BDFBuddyProfile (CoreDataGeneratedAccessors)

- (void)addAgeObject:(BDFAge *)value;
- (void)removeAgeObject:(BDFAge *)value;
- (void)addAge:(NSSet *)values;
- (void)removeAge:(NSSet *)values;

- (void)addCountryObject:(BDFCountry *)value;
- (void)removeCountryObject:(BDFCountry *)value;
- (void)addCountry:(NSSet *)values;
- (void)removeCountry:(NSSet *)values;

- (void)addGameplayObject:(BDFGameplay *)value;
- (void)removeGameplayObject:(BDFGameplay *)value;
- (void)addGameplay:(NSSet *)values;
- (void)removeGameplay:(NSSet *)values;

- (void)addLanguageObject:(BDFLanguage *)value;
- (void)removeLanguageObject:(BDFLanguage *)value;
- (void)addLanguage:(NSSet *)values;
- (void)removeLanguage:(NSSet *)values;

- (void)addPlatformObject:(BDFPlatform *)value;
- (void)removePlatformObject:(BDFPlatform *)value;
- (void)addPlatform:(NSSet *)values;
- (void)removePlatform:(NSSet *)values;

- (void)addPlayingObject:(BDFPlaying *)value;
- (void)removePlayingObject:(BDFPlaying *)value;
- (void)addPlaying:(NSSet *)values;
- (void)removePlaying:(NSSet *)values;

- (void)addSkillObject:(BDFSkill *)value;
- (void)removeSkillObject:(BDFSkill *)value;
- (void)addSkill:(NSSet *)values;
- (void)removeSkill:(NSSet *)values;

- (void)addTimeObject:(BDFTime *)value;
- (void)removeTimeObject:(BDFTime *)value;
- (void)addTime:(NSSet *)values;
- (void)removeTime:(NSSet *)values;

- (void)addVoiceObject:(BDFVoice *)value;
- (void)removeVoiceObject:(BDFVoice *)value;
- (void)addVoice:(NSSet *)values;
- (void)removeVoice:(NSSet *)values;

@end
