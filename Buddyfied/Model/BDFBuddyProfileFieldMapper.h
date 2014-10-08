//
//  BDFBuddyProfileFieldMapper.h
//  Buddyfied
//
//  Created by Tom Gilbert on 10/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDFBuddyProfileFieldMapper : NSObject

-(instancetype)init;

- (NSString*) serverFieldForModelProperty:(NSString*)propertyName;
- (NSString*) serverIdForModelProperty:(NSString*)propertyName;

- (NSString*) modelPropertyForServerField:(NSString*)serverField;
- (NSString*) modelPropertyForServerId:(NSString*)serverId;

- (NSString*) avatarFullImageUrl:(NSDictionary*)serverData;

@end
