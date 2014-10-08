//
//  BDFSettings.m
//  Buddyfied
//
//  Created by Tom Gilbert on 11/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFSettings.h"

const CGFloat BDF_MinCellHeight = 44.0;


@implementation BDFSettings
@synthesize userName=_userName;
@synthesize password=_password;
@synthesize buddyHelp=_buddyHelp;
@synthesize buddySite=_buddySite;
@synthesize buddyLostPassword=_buddyLostPassword;
@synthesize buddyGuest=_buddyGuest;
@synthesize buddyGuestPassword=_buddyGuestPassword;
@synthesize buddyReportUserEmail=_buddyReportUserEmail;

+ (instancetype) sharedSettings
{
    static BDFSettings *retVal = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retVal = [[self alloc] init];
    });
    
    return retVal;
}

- (UIColor*) backgroundColor
{
    //return [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
    return [UIColor blackColor];
}

- (UIColor*) cellSelectionColor
{
    return [UIColor colorWithRed:(0.2) green:(0.2) blue:(0.2) alpha:1.0];
}

- (UIColor*) requiredBackgroundColor
{
    return [UIColor colorWithRed:(0.6) green:(0.2) blue:(0.2) alpha:1.0];
}

-(NSString*)userName
{
    if (!_userName)
    {
        [self getUserNameAndPassword];
    }
    return _userName;
}

-(void)setUserName:(NSString *)userName
{
    if (![_userName isEqualToString:userName])
    {
        _userName = userName;
        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"userName"];
    }
}

-(NSString*)password
{
    if (!_password)
    {
        [self getUserNameAndPassword];
    }
    return _password;
}

-(void)setPassword:(NSString *)password
{
    if (![_password isEqualToString:password])
    {
        _password = password;
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
    }
}

-(NSString*) userId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
}

-(void)setUserId:(NSString *)userId
{
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"userId"];
}

-(NSString*) email
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
}

-(void)setEmail:(NSString *)email
{
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"email"];
}

-(BOOL)loggedIn
{
    NSNumber* val = [[NSUserDefaults standardUserDefaults] objectForKey:@"loggedIn"];
    return [val boolValue];
}

-(void)setLoggedIn:(BOOL)loggedIn
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:loggedIn] forKey:@"loggedIn"];
}

- (NSNumber*) activeMenuIndex
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"activeMenuIndex"];
}

-(void)setActiveMenuIndex:(NSNumber*)activeMenuIndex
{
    [[NSUserDefaults standardUserDefaults] setObject:activeMenuIndex forKey:@"activeMenuIndex"];
}

- (NSString*) buddyHelp
{
    if (!_buddyHelp)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
        NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];
        _buddyHelp = [settings objectForKey:@"buddyHelp"];
    }
    return _buddyHelp;
}

- (NSString*) buddyReportUserEmail
{
    if (!_buddyReportUserEmail)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
        NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];
        _buddyReportUserEmail = [settings objectForKey:@"buddyReportUserEmail"];
    }
    return _buddyReportUserEmail;
}

- (NSString*) buddySite
{
    if (!_buddySite)
    {
        NSString* useBuddySite = [[NSUserDefaults standardUserDefaults] objectForKey:@"buddySite"];
        if (!useBuddySite)
        {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
            NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];
            useBuddySite = [settings objectForKey:@"buddySite"];
        }
        _buddySite = useBuddySite;
    }
    return _buddySite;
}

- (NSString*) buddyLostPassword
{
    if (!_buddyLostPassword)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
        NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];
        _buddyLostPassword = [settings objectForKey:@"buddyLostPassword"];
    }
    return _buddyLostPassword;
}

- (BOOL) isGuestUser
{
    return [self.userName isEqualToString:self.buddyGuest];
}

- (NSString*) buddyGuest
{
    if (!_buddyGuest)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
        NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];
        _buddyGuest = [settings objectForKey:@"buddyGuest"];
    }
    return _buddyGuest;
}

- (NSString*) buddyGuestPassword
{
    if (!_buddyGuestPassword)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
        NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];
        _buddyGuestPassword = [settings objectForKey:@"buddyGuestPassword"];
    }
    return _buddyGuestPassword;
}

- (void) getUserNameAndPassword
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lUserName = [defaults objectForKey:@"userName"];
    NSString *lPassword = [defaults objectForKey:@"password"];
    
    if (!lUserName || !lPassword)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
        NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];
        lUserName = [settings objectForKey:@"userName"];
        lPassword = [settings objectForKey:@"password"];
    }
    
    _userName = lUserName;
    _password = lPassword;
}

@end
