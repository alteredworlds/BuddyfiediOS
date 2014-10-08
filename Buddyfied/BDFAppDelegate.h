//
//  BDFAppDelegate.h
//  Buddyfied
//
//  Created by Tom Gilbert on 10/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDFMyProfile.h"
#import "BDFClient.h"
#import "BDFUserManagement.h"

@class BDFSearchRequest;

@interface BDFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic, readonly) UIManagedDocument *uiManagedDocument;

@property (nonatomic, strong, readonly) BDFClient* bdfClient;

@property (strong, nonatomic, readonly) id<BDFUserManagement> userClient;

@property (strong, nonatomic, readonly) BDFSearchRequest *searchRequest;

@property (strong, nonatomic, readonly) BDFMyProfile* profile;

@property (nonatomic) BOOL showNetworkActivity;

@property (nonatomic, strong, readonly) UIImage* avatarPlaceholder;

-(void)initDocumentIfRequired;

-(void)clearPersonalData;

@end
