//
//  BDFShowAppMenuDelegate.h
//  Buddyfied
//
//  Created by Tom Gilbert on 13/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BDFMasterDetailController <NSObject>

@property (nonatomic) BOOL scrollingEnabled;
@property (nonatomic) NSUInteger homePage;

-(void)toggleMaster:(id)sender;
-(void)showMaster:(BOOL)animated;
-(void)showDetail:(BOOL)animated;

-(void)switchToDetail:(NSString*)detailViewControllerId;
-(void)setActiveMenuItemNamed:(NSString*)name;
-(void)setActiveMenuItemAtRow:(NSUInteger)row;

@end
