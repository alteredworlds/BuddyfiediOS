//
//  BDFMasterMenuItem.h
//  Buddyfied
//
//  Created by Tom Gilbert on 15/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDFMasterMenuItem : NSObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * iconName;
@property (nonatomic, retain) NSString * viewControllerIdentifier;

- (instancetype) initWithName:(NSString*)name
     viewControllerIdentifier:(NSString*)viewControllerIdentifier
                     iconName:iconName;

@end
