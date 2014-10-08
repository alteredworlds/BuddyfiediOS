//
//  BDFStaticDataManger.m
//  Buddyfied
//
//  Created by Tom Gilbert on 20/05/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFStaticDataManger.h"
#import "BDFEntityNames.h"
#import "BDFSEttings.h"
#import "BDFPlayerAttribute+Create.h"
#import "BDFAppDelegate.h"
#import <CoreData/CoreData.h>

static NSString* const PlatformKey = @"platform";
static NSString* const CountryKey = @"country";
static NSString* const GameplaymKey = @"gameplay";
static NSString* const GameKey = @"game";
static NSString* const SkillKey = @"skill";
static NSString* const TimeKey = @"times";
static NSString* const LanguagesKey = @"languages";


static NSString* const BuddifiedStaticDataUrl =
@"%@wp-content/themes/buddyfied/_inc/ajax/autocomplete.php?mode=%@&q=";

// for non-AFNetworking method
typedef void (^BuddyfiedReadDataFromUrlCompletionBlock)(NSString *url, NSDictionary *results, NSError *error);


@interface BDFStaticDataManger()

@end


@implementation BDFStaticDataManger
{
    NSMutableDictionary* _cache;
    dispatch_queue_t _queue;
}

+ (instancetype) shared
{
    static BDFStaticDataManger *retVal = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retVal = [[self alloc] init];
    });
    
    return retVal;
}

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        _cache = [[NSMutableDictionary alloc] init];
        _queue = dispatch_queue_create("com.alteredworlds.cachequeue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}


-(BOOL)isRequestInProgressForEntityNamed:(NSString*)entityName
{
    __block BOOL retVal;
    dispatch_sync(_queue, ^{
        id obj = [_cache objectForKey: entityName];
        retVal = nil != obj;
    });
    return retVal;
}

- (void)setRequestInProgress:(id)request forEntityNamed:(NSString*)entityName
{
    dispatch_barrier_async(_queue, ^{
        [_cache setObject: request forKey: entityName];
    });
}

- (void)setRequestFinishedForEntityNamed:(NSString*)entityName
{
    dispatch_barrier_async(_queue, ^{
        [_cache removeObjectForKey: entityName];
    });
}



-(void) loadStaticData:(NSManagedObjectContext*)managedObjectContext removeExisting:(BOOL)removeExisting
{
    // platform
    [self loadStaticForEntityNamed:PLATFORM_ENTITY
            inManagedObjectContext:managedObjectContext
                    removeExisting:removeExisting
                   completionBlock:nil];
    // country
    [self loadStaticForEntityNamed:COUNTRY_ENTITY
            inManagedObjectContext:managedObjectContext
                    removeExisting:removeExisting
                   completionBlock:nil];
    // gameplay
    [self loadStaticForEntityNamed:GAMEPLAY_ENTITY
            inManagedObjectContext:managedObjectContext
                    removeExisting:removeExisting
                   completionBlock:nil];
    // game
    [self loadStaticForEntityNamed:PLAYING_ENTITY
            inManagedObjectContext:managedObjectContext
                    removeExisting:removeExisting
                   completionBlock:nil];
    // language
    [self loadStaticForEntityNamed:LANGUAGE_ENTITY
            inManagedObjectContext:managedObjectContext
                    removeExisting:removeExisting
                   completionBlock:nil];
    // skill
    [self loadStaticForEntityNamed:SKILL_ENTITY
            inManagedObjectContext:managedObjectContext
                    removeExisting:removeExisting
                   completionBlock:nil];
    // time
    [self loadStaticForEntityNamed:TIME_ENTITY
            inManagedObjectContext:managedObjectContext
                    removeExisting:removeExisting
                   completionBlock:nil];
}

-(NSString*)remoteKeyForEntityNamed:(NSString*)entityName
{
    NSString* retVal = nil;
    if ([entityName isEqualToString:PLATFORM_ENTITY])
        retVal = PlatformKey;
    else if ([entityName isEqualToString:COUNTRY_ENTITY])
        retVal = CountryKey;
    else if ([entityName isEqualToString:PLAYING_ENTITY])
        retVal = GameKey;
    else if ([entityName isEqualToString:LANGUAGE_ENTITY])
        retVal = LanguagesKey;
    else if ([entityName isEqualToString:GAMEPLAY_ENTITY])
        retVal = GameplaymKey;
    else if ([entityName isEqualToString:SKILL_ENTITY])
        retVal = SkillKey;
    else if ([entityName isEqualToString:TIME_ENTITY])
        retVal = TimeKey;
    return retVal;
}

// iff(
// no load already in progress &&
// we do not already have static data)
// then kick of static data load.
//
-(void) initialStaticDataLoadIfNeeded:(NSManagedObjectContext*)managedObjectContext
{
    // we're gonna just check ONE entity here, not the whole lot.
    NSString* entityName = PLATFORM_ENTITY;
    // is there an existing data load in progress?
    if (![self isRequestInProgressForEntityNamed:entityName])
    {
        // No load in progress. But do we already have the data?
        NSError *error;
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        request.fetchLimit = 1;
        NSArray *matches = [managedObjectContext executeFetchRequest:request error:&error];
        if (error)
        {
            NSLog(@"Failed to query entity %@: %@", entityName, error);
        }
        else if (!matches || (0 == matches.count))
        {
            // We don't have any data.
            // Safe to assume we need to kick off the full static data load...
            [self loadStaticData:managedObjectContext removeExisting:NO];
        }
    }
}

//
// ISSUES with AFNetworking version commented out below:
// (1) data returned by Buddyfied is tagged as text/html not text/json
// (2) with code as implemented, data load appears to be on foreground thread
//
//-(void)loadStaticForEntityNamed:(NSString*)entityName
//                          inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
//                                  removeExisting:(BOOL)removeExisting
//                                 completionBlock:(BuddyfiedReadStaticCompletionBlock)completion
//{
//    if ([self isRequestInProgressForEntityNamed:entityName])
//        return;
//    //
//    NSString* urlStr = [NSString stringWithFormat:BuddifiedStaticDataUrl,
//                        [BDFSettings sharedSettings].buddySite,
//                        [self remoteKeyForEntityNamed:entityName]];
//    NSURL *url = [NSURL URLWithString:urlStr];
//    NSURLRequest* urlRequest = [NSURLRequest requestWithURL:url];
//
//    AFJSONRequestOperation *request = nil;
//    request = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest
//               success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
//               {
//                   NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//                   backgroundContext.parentContext = managedObjectContext;
//                   backgroundContext.undoManager = nil;
//                   
//                   [backgroundContext performBlockAndWait:^{
//                       [BDFPlayerAttribute loadEntitiesNamed:entityName
//                                              fromDictionary:(NSDictionary*)JSON
//                                      inManagedObjectContext:backgroundContext
//                                              removeExisting:removeExisting];
//                       [backgroundContext save:nil];
//                       
//                       [managedObjectContext performBlock:^{
//                           [((BDFAppDelegate*)[UIApplication sharedApplication].delegate).uiManagedDocument updateChangeCount:UIDocumentChangeDone];
//                       }];
//                   }];
//                   [self setRequestFinishedForEntityNamed:entityName];
//                   if (completion)
//                       completion(entityName, nil);
//               }
//               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
//               {
//                   [self setRequestFinishedForEntityNamed:entityName];
//                   if (completion)
//                       completion(entityName, error);
//               }
//               ];
//    [self setRequestInProgress:request forEntityNamed:entityName];
//    [request start];
//}

-(void)loadStaticForEntityNamed:(NSString*)entityName
         inManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
                 removeExisting:(BOOL)removeExisting
                completionBlock:(BuddyfiedReadStaticCompletionBlock)completion
{
    if ([self isRequestInProgressForEntityNamed:entityName])
    {
        if (completion)
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(entityName, nil);
            });
        return;
    }
    
    ((BDFAppDelegate*)[UIApplication sharedApplication].delegate).showNetworkActivity = YES;
    //
    NSString* remoteKey = [self remoteKeyForEntityNamed:entityName];
    NSString* url = [NSString stringWithFormat:BuddifiedStaticDataUrl,
                     [BDFSettings sharedSettings].buddySite,
                     remoteKey];
    //
    [self setRequestInProgress:remoteKey forEntityNamed:entityName];
    [self readJSONFromURL:url completionBlock:^(NSString *url, NSDictionary *results, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             ((BDFAppDelegate*)[UIApplication sharedApplication].delegate).showNetworkActivity = NO;
         });

         if (results && !error)
         {
             NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
             backgroundContext.parentContext = managedObjectContext;
             backgroundContext.undoManager = nil;
             
             [backgroundContext performBlockAndWait:^{
                 [BDFPlayerAttribute loadEntitiesNamed:entityName
                                        fromDictionary:results
                                inManagedObjectContext:backgroundContext
                                        removeExisting:removeExisting];
                 [backgroundContext save:nil];
                 
                 [managedObjectContext performBlock:^{
                     [((BDFAppDelegate*)[UIApplication sharedApplication].delegate).uiManagedDocument updateChangeCount:UIDocumentChangeDone];
                 }];
             }];
         }
         [self setRequestFinishedForEntityNamed:entityName];
         //
         dispatch_async(dispatch_get_main_queue(), ^{
             if (completion)
                 completion(entityName, error);
         });
     }];
}


- (void) readJSONFromURL:(NSString *)url
         completionBlock:(BuddyfiedReadDataFromUrlCompletionBlock) completionBlock
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSDictionary *searchResultsDict = nil;
        NSError *error = nil;
        NSString *searchResultString = [NSString stringWithContentsOfURL:[NSURL URLWithString:url]
                                                                encoding:NSUTF8StringEncoding
                                                                   error:&error];
        if (!error)
        {
            // Parse the JSON Response
            NSData *jsonData = [searchResultString dataUsingEncoding:NSUTF8StringEncoding];
            searchResultsDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:kNilOptions
                                                                  error:&error];
        }
        else
        {
            // stringWithContentsOfURL returns an obscure message for internet connection down
            // in this case. Translate explicitly to match elsewhere, even though this is a cludge
            // that loses any system-automated localization, how could the message
            // GET any worse...!? At least it is meaningful in English!
            //
            if (NSNotFound != [error.description rangeOfString:@"(Cocoa error 256.)"].location)
            {
                error = [NSError errorWithDomain:NSURLErrorDomain
                                            code:-1009
                                        userInfo:@{NSLocalizedDescriptionKey: @"The Internet connection appears to be offline.",
                                                   NSUnderlyingErrorKey: error}];
            }
        }
        //
        // no matter which codepath, we need to call the completionBlock
        //  with arguments that should now be apropriate
        if (completionBlock)
            completionBlock(url, searchResultsDict, error);
    });
}


@end
