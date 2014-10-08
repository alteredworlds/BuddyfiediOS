//
//  UIViewController+Helpers.m
//  iCookery
//
//  Created by Tom Gilbert on 21/02/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "UIViewController+Helpers.h"

@implementation UIViewController (Helpers)

-(UIViewController*) topViewController;
{
    UIViewController* retVal = self;
    if ([retVal isKindOfClass:[UINavigationController class]])
        retVal = [(UINavigationController*)retVal topViewController];
    return retVal;
}

@end
