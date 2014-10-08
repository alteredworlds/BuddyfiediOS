//
//  BDFBuddyTableViewCell.h
//  Buddyfied
//
//  Created by Tom Gilbert on 29/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BDFBuddyTableViewCell <NSObject>

@property (weak, nonatomic) NSString* name;
@property (weak, nonatomic) NSString* value;

@end
