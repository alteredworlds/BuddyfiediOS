//
//  BDFSettings.h
//  Buddyfied
//
//  Created by Tom Gilbert on 11/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>

extern CGFloat const BDF_MinCellHeight;


@interface BDFSettings : NSObject

+ (instancetype) sharedSettings;

@property (strong, nonatomic, readonly) NSString* buddyHelp;
@property (strong, nonatomic, readonly) NSString* buddySite;
@property (strong, nonatomic, readonly) NSString* buddyLostPassword;
@property (strong, nonatomic, readonly) NSString* buddyGuest;
@property (strong, nonatomic, readonly) NSString* buddyGuestPassword;
@property (strong, nonatomic, readonly) NSString* buddyReportUserEmail;
@property (strong, nonatomic) NSString* userName;
@property (strong, nonatomic) NSString* password;
@property (strong, nonatomic) NSString* userId;
@property (strong, nonatomic) NSString* email;
@property (nonatomic) BOOL loggedIn;
@property (nonatomic, readonly) BOOL isGuestUser;
@property (nonatomic, strong, readonly) UIColor* backgroundColor;
@property (nonatomic, strong, readonly) UIColor* cellSelectionColor;
@property (nonatomic, strong, readonly) UIColor* requiredBackgroundColor;

@property (nonatomic) NSNumber* activeMenuIndex;

@end
