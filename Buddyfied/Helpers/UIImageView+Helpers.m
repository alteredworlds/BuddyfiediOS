//
//  UIImageView+Helpers.m
//  Buddyfied
//
//  Created by Tom Gilbert on 06/06/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "UIImageView+Helpers.h"
#import <AVFoundation/AVFoundation.h>

@implementation UIImageView (Helpers)

- (void) applyBorder:(UIColor*)color
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10.0;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.layer.borderWidth = 4;
}

@end
