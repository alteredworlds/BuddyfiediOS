//
//  BDFMasterMenuItem.m
//  Buddyfied
//
//  Created by Tom Gilbert on 15/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFMasterMenuItem.h"

@implementation BDFMasterMenuItem

- (instancetype) initWithName:(NSString*)name
     viewControllerIdentifier:(NSString*)viewControllerIdentifier
                     iconName:iconName
{
    self = [super init];
    if (self)
    {
        _name = name;
        _viewControllerIdentifier = viewControllerIdentifier;
        _iconName = iconName;
    }
    return self;
}

@end
