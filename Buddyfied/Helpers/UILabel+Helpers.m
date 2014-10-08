//
//  UILabel+Helpers.m
//  Buddyfied
//
//  Created by Tom Gilbert on 06/06/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "UILabel+Helpers.h"

@implementation UILabel (Helpers)

-(void) setFontBold
{
    UIFontDescriptor * fontD = [self.font.fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    self.font = [UIFont fontWithDescriptor:fontD size:0];
}

@end
