//
//  BDFAppDelegate.m
//  Buddyfied
//
//  Created by Tom Gilbert on 10/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFAppDelegate.h"
#import "BDFAppDelegate+BasicConfiguration.h"
#import "BDFStaticDataManger.h"
#import "BDFUIConfigurationAvailablity.h"
#import "BDFSearchRequest+Create.h"
#import "BDFManagedDocument.h"
#import "BDFSettings.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "BDFEntityNames.h"
#import "BDFMyProfile+Helpers.h"
#import "BDFSearchRequest+Helpers.h"
#import "BDFJSONAPIUserClient.h"

@interface BDFAppDelegate()

@property (strong, nonatomic, readwrite) UIManagedDocument *uiManagedDocument;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) BDFSearchRequest *searchRequest;
@property (strong, nonatomic) BDFMyProfile *profile;
@property (strong, nonatomic) id documentReadyObserver;

-(UIManagedDocument *) createUIManagedDocument;
-(void) documentIsReady:(BOOL)wasCreated;

@end

@implementation BDFAppDelegate
@synthesize profile=_profile;
@synthesize avatarPlaceholder=_avatarPlaceholder;
@synthesize bdfClient=_bdfClient;
@synthesize userClient=_userClient;

static NSString* const OldDocumentName = @"BuddyfiedUIConfig";
static NSString* const DocumentName = @"BuddyfiedDataModel";

//static NSString* const OldDocumentName = @"BuddyfiedDataModel";
//static NSString* const DocumentName = @"BuddyfiedUIConfig";

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.documentReadyObserver];
}

- (BDFClient*) bdfClient
{
    if (!_bdfClient)
    {
        _bdfClient = [[BDFClient alloc] init];
    }
    return _bdfClient;
}

- (id<BDFUserManagement>) userClient
{
    if (!_userClient)
    {
        _userClient = [[BDFJSONAPIUserClient alloc] init];
    }
    return _userClient;
}

-(BDFSearchRequest*) searchRequest
{
    if (!_searchRequest)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:SearchRequestEntityName];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", @"Default"];
        
        NSError* error;
        NSArray* res = [self.managedObjectContext executeFetchRequest:request error:&error];
        if (res.count == 1)
        {
            _searchRequest = [res firstObject];
        }
    }
    return _searchRequest;
}

-(UIImage*)avatarPlaceholder
{
    if (!_avatarPlaceholder)
    {
        _avatarPlaceholder = [UIImage imageNamed:@"avatar"];
    }
    return _avatarPlaceholder;
}

-(BDFMyProfile*) profile
{
    if (!_profile)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:MYPROFILE_ENTITY];
        request.fetchLimit = 1;
        
        NSError* error;
        NSArray* res = [self.managedObjectContext executeFetchRequest:request error:&error];
        if (res.count == 1)
        {
            _profile = [res firstObject];
        }
        else
        {
            // empty profile
            _profile = [NSEntityDescription insertNewObjectForEntityForName:MYPROFILE_ENTITY
                                                     inManagedObjectContext:self.managedObjectContext];
        }
    }
    return _profile;
}

-(BOOL) showNetworkActivity
{
    
    return [AFNetworkActivityIndicatorManager sharedManager].isNetworkActivityIndicatorVisible;
}

-(void) setShowNetworkActivity:(BOOL)showNetworkActivity
{
    if (showNetworkActivity)
    {
        [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    }
    else
    {
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //
    [[UIView appearance] setTintColor:[UIColor orangeColor]];
    // when using AFNetworking, show network activity indicator
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    //
    self.uiManagedDocument = [self createUIManagedDocument];
    //
    // NOTE UIManagedDocument not ready to use yet, file ops are async
    if (![BDFSettings sharedSettings].loggedIn)
    {
        [self.window makeKeyAndVisible];
        [self.window.rootViewController performSegueWithIdentifier:@"modalSegue" sender:self];
    }
    //
    return YES;
}

-(void) documentIsReady:(BOOL)wasCreated
{
    if (self.uiManagedDocument.documentState == UIDocumentStateNormal)
    {
        NSManagedObjectContext* context = self.uiManagedDocument.managedObjectContext;
        context.undoManager = nil;
        //
        if (wasCreated)
        {
            [self setupBasicConfig:context];
        }
        self.managedObjectContext = context;
        //
        // if database updated for logged in user, static must be re-requested
        if (wasCreated && [BDFSettings sharedSettings].loggedIn)
        {
            // everything is ready, go ahead and start the static data load
            [[BDFStaticDataManger shared] initialStaticDataLoadIfNeeded:self.managedObjectContext];
        }
        //
        // let everyone who might be interested know this context is available
        NSDictionary *userInfo = context ? @{ BDFUIConfigurationAvailablityContext : context,
                                              @"wasCreated" : [NSNumber numberWithBool:wasCreated] } : nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:BDFUIConfigurationAvailablityNotification
                                                            object:self
                                                          userInfo:userInfo];
    }
}

-(void)initDocumentIfRequired
{
    // It's possible this function could be called before the UIManagedDocument is ready.
    if (self.managedObjectContext)
    {
        // everything is ready, go ahead and start the static data load (if needed)
        [[BDFStaticDataManger shared] initialStaticDataLoadIfNeeded:self.managedObjectContext];
    }
    else
    {
        // UIManagedObjectDocument is NOT yet ready, so schedule data load on notification
        __weak BDFAppDelegate* weakSelf = self;
        self.documentReadyObserver = [[NSNotificationCenter defaultCenter] addObserverForName:BDFUIConfigurationAvailablityNotification
                                                                                       object:nil
                                                                                        queue:nil
                                                                                   usingBlock:^(NSNotification *note)
                                      {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [[BDFStaticDataManger shared] initialStaticDataLoadIfNeeded:weakSelf.managedObjectContext];
                                          });
                                      }];
    }
}

-(void)removeOutOfDateDocumentVersionsIfRequired:(NSFileManager*)fileManager documentsDirectory:(NSURL*)docDir
{
    NSURL*  url = [docDir URLByAppendingPathComponent:OldDocumentName];
    if ([fileManager fileExistsAtPath:[url path]])
    {
        NSError* error;
        if ([fileManager removeItemAtURL:url error:&error])
        {
            NSLog(@"Removed old version of document: %@", OldDocumentName);
        }
        else
        {
            NSLog(@"Failed to remove old document: %@", OldDocumentName);
        }
    }
}

-(UIManagedDocument *) createUIManagedDocument
{
    UIManagedDocument*  retVal = nil;
    NSFileManager*      fileManager = [NSFileManager defaultManager];
    NSURL*              docDir = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                      inDomains:NSUserDomainMask] firstObject];
    //
    // we don't need to migrate from older versions of Core Data model since
    // this is just a local CACHE, not backed up in iCloud
    [self removeOutOfDateDocumentVersionsIfRequired:fileManager documentsDirectory:docDir];
    //
    // at this point the UIManagedDocument instance will be created but underlying file
    // NOT opened or created as needed.
    NSURL* url = [docDir URLByAppendingPathComponent:DocumentName];
    retVal = [[BDFManagedDocument alloc] initWithFileURL:url];
    //
    // first, check to see if the file already exists
    BOOL fileExists = [fileManager fileExistsAtPath:[url path]];
    //
    // NOTE the file operations are ASYNC
    if (fileExists)
    {
        [retVal openWithCompletionHandler:^(BOOL success) {
            if (success)
                [self documentIsReady:NO];
            else
                NSLog(@"Couldn't open document at %@", url);
        }];
    }
    else
    {
        [retVal saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success)
            {
                [self addSkipBackupAttributeToItemAtURL:url];
                [self documentIsReady:YES];
            }
            else
                NSLog(@"Couldn't create document at %@", url);
        }];
    }
    return retVal;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

-(void)clearPersonalData
{
    // need to clear all user-preference data
    // including last search, retrieved profile information
    [BDFSettings sharedSettings].loggedIn = NO;
    [BDFSettings sharedSettings].activeMenuIndex = nil;
    [BDFSettings sharedSettings].password = nil;
    [BDFSettings sharedSettings].userName = nil;
    [BDFSettings sharedSettings].email = nil;
    //
    // cleanup SEARCH request and associated RESULTS
    [self.searchRequest clear];
    //
    // set the locally cached MyProfile reference to nil
    self.profile = nil;
    // there's only one MyProfile instance so can clear all of this entity type
    [BDFMyProfile clearAllFromManagedObjectContext:self.managedObjectContext];
    //
    [self.uiManagedDocument updateChangeCount:UIDocumentChangeDone];
}

@end
