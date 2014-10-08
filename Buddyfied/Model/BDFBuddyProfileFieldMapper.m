//
//  BDFBuddyProfileFieldMapper.m
//  Buddyfied
//
//  Created by Tom Gilbert on 10/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFBuddyProfileFieldMapper.h"

@interface BDFBuddyProfileFieldMapper()

@property (nonatomic, strong) NSDictionary* fieldForProperty;
@property (nonatomic, strong) NSDictionary* idForProperty;

@property (nonatomic, strong) NSDictionary* propertyForField;
@property (nonatomic, strong) NSDictionary* propertyForId;

@end

@implementation BDFBuddyProfileFieldMapper

static NSString* const BUDDY_AVATAR_KEY =  @"avatar";
static NSString* const BUDDY_AVATAR_FULL_KEY =  @"full";

-(instancetype)init
{
    if (self = [super init])
    {
        // mappings between server designation & property name
        self.idForProperty = @{@"name" : @"1",
                                @"platform" : @"2",
                                @"playing" : @"4",
                                @"gameplay" : @"5",
                                @"country" : @"6",
                                @"skill" : @"7",
                                @"years" : @"8",
                                @"voice" : @"9",
                                @"time" : @"152",
                                @"language" : @"153",
                                @"comments" : @"167"};
        self.fieldForProperty = [self buildFieldsFromIds:self.idForProperty];
        self.propertyForField = [self buildReverseLookup:self.fieldForProperty];
        self.propertyForId = [self buildReverseLookup:self.idForProperty];
    }
    return self;
}

- (NSString*) serverFieldForModelProperty:(NSString*)propertyName
{
    return self.fieldForProperty[propertyName];
}

- (NSString*) serverIdForModelProperty:(NSString*)propertyName
{
    return self.idForProperty[propertyName];
}

- (NSString*) modelPropertyForServerField:(NSString*)serverField
{
    return self.propertyForField[serverField];
}

- (NSString*) modelPropertyForServerId:(NSString*)serverId
{
    return self.propertyForId[serverId];
}

-(NSString*) avatarFullImageUrl:(NSDictionary*)serverData
{
    return serverData[BUDDY_AVATAR_KEY][BUDDY_AVATAR_FULL_KEY];
}

-(NSDictionary*) buildFieldsFromIds:(NSDictionary*)source
{   // now build the reverse lookup dictionary
    NSMutableDictionary* builder = [[NSMutableDictionary alloc] initWithCapacity:source.count];
    for (NSString* key in source)
    {
        builder[key] = [NSString stringWithFormat:@"field_%@", source[key]];
    }
    return builder;
}

-(NSDictionary*) buildReverseLookup:(NSDictionary*)source
{   // now build the reverse lookup dictionary
    NSMutableDictionary* builder = [[NSMutableDictionary alloc] initWithCapacity:source.count];
    for (NSString* key in source)
    {
        builder[source[key]] = key;
    }
    return builder;
}

@end
