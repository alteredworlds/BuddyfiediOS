//
//  BDFJSONAPIUserClient.m
//  Buddyfied
//
//  Created by Tom Gilbert on 02/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFJSONAPIUserClient.h"
#import "AFNetworking.h"
#import "BDFSettings.h"
#import "BDFError.h"

@interface BDFJSONAPIUserClient ()

@property (nonatomic, strong) NSString* authCookie;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation BDFJSONAPIUserClient

static NSString* BuddyfiedMagicTokenURL = @"%@api/get_nonce/?controller=user&method=%@";
static NSString* BuddyfiedRegisterUserURL = @"%@api/user/buddypress_register?username=%@&nonce=%@&email=%@&password=%@";
static NSString* BuddyfiedUpdateProfileURL = @"%@api/user/xprofile_multi_update/?cookie=%@";
static NSString* BuddyfiedGenerateCookieURL = @"%@api/user/generate_auth_cookie/?nonce=%@&username=%@&password=%@";


#pragma mark - public interface

-(instancetype)init
{
    if (self = [super init])
    {
        self.operationQueue = [[NSOperationQueue alloc] init];
        [self.operationQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

-(void) cancel
{
    for (AFHTTPRequestOperation *operation in [self.operationQueue operations])
    {
        [operation cancel];
    }
}

-(void) registerNewUser:(NSString*)user
           withPassword:(NSString*)password
        andEmailAddress:(NSString*)email
              usingData:(NSDictionary*)profileData
        completionBlock:(BDFUserManagementCompletionBlock)completion
{
    BDFJSONAPIUserClient* __weak weakSelf = self;
    [self  grabNonceForUser:user
               withPassword:password
                  forMethod:@"register"
            completionBlock:^(id result, NSError *error) {
                if (error)
                {
                    NSLog(@"registerNewUser failed to grabNonceForUser %@", error);
                    if (completion)
                        completion(result, error);
                }
                else
                {
                    [weakSelf registerNewUserUsingNOnceToken:result
                                                     forUser:user
                                                withPassword:password
                                             andEmailAddress:email
                                                   usingData:profileData
                                             completionBlock:completion];
                }
            }];
}

-(void) updateProfileForUser:(NSString*)user
                withPassword:(NSString*)password
                   usingData:(NSDictionary*)profileData
             completionBlock:(BDFUserManagementCompletionBlock)completion
{
    BDFJSONAPIUserClient* __weak weakSelf = self;
    [self grabAuthCookieIfNeededForUser:user withPassword:password completionBlock:^(id result, NSError *error) {
        if (error)
        {
            NSLog(@"ERROR: updateProfileForUser failed to get authCookie %@", error);
            if (completion)
                completion(result, error);
        }
        else
        {
            [weakSelf updateProfileUsingAuthCookie:self.authCookie
                                          withData:profileData
                                   completionBlock:^(id result, NSError *error) {
                                       if (error)
                                       {
                                           NSLog(@"ERROR: updateProfileForUser failed %@", error);
                                       }
                                       if (completion)
                                           completion(result, error);
                                   }];
        }
    }];
}

#pragma mark - Internal
-(void) grabNonceForUser:(NSString*)user
            withPassword:(NSString*)password
               forMethod:(NSString*)method
         completionBlock:(BDFUserManagementCompletionBlock)completion
{
    // FIRST we need the magic token, retrieved via an initial call
    NSString* urlStr = [NSString stringWithFormat:BuddyfiedMagicTokenURL,
                        [BDFSettings sharedSettings].buddySite,
                        method];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest* urlRequest = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation* jsonRequest = [AFJSONRequestOperation
                                           JSONRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                               //
                                               // nonce call to server completed OK.
                                               NSError* error = nil;
                                               NSString* result = nil;
                                               if (![JSON isKindOfClass:[NSDictionary class]])
                                               {
                                                   error = [BDFJSONAPIUserClient invalidResponseType];
                                               }
                                               else
                                               {
                                                   result = ((NSDictionary*)JSON)[@"nonce"];
                                                   if (!result.length)
                                                   {
                                                       error = [BDFJSONAPIUserClient invalidResponseType];
                                                   }
                                               }
                                               if (completion)
                                               {
                                                   completion(result, error);
                                               }
                                           }
                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                               if (completion)
                                               {
                                                   completion(nil, error);
                                               }
                                           }];
    [self.operationQueue addOperation:jsonRequest];
}

-(void) grabAuthCookieIfNeededForUser:(NSString*)user
                         withPassword:(NSString*)password
                      completionBlock:(BDFUserManagementCompletionBlock)completion
{
    NSError* error = nil;
    if (self.authCookie)
    {   // we already have it...
        if (completion)
            completion(self.authCookie, error);
    }
    else
    {
        // we need to get the blasted thing...
        // first we're going to need an NONCE token
        BDFJSONAPIUserClient* __weak weakSelf = self;
        [self  grabNonceForUser:user
                   withPassword:password
                      forMethod:@"generate_auth_cookie"
                completionBlock:^(id result, NSError *error) {
                    if (error)
                    {
                        NSLog(@"grabAuthCookieIfNeededForUser failed to grabNonceForUser %@", error);
                        if (completion)
                            completion(result, error);
                    }
                    else
                    {
                        [weakSelf generateAuthCookieForUser:user
                                           withPassword:password
                                               andNonce:result
                                        completionBlock:completion];
                    }
                }];
    }
}

-(void) generateAuthCookieForUser:(NSString*)user
                     withPassword:(NSString*)password
                         andNonce:(NSString*)nonce
                  completionBlock:(BDFUserManagementCompletionBlock)completion
{
    // make sure we are consistent...
    self.authCookie = nil;
    //
    NSString* urlStr = [NSString stringWithFormat:BuddyfiedGenerateCookieURL,
                        [BDFSettings sharedSettings].buddySite,
                        nonce,
                        user,
                        password];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest* urlRequest = [NSURLRequest requestWithURL:url];
    
    BDFJSONAPIUserClient* __weak weakSelf = self;
    AFJSONRequestOperation* jsonRequest = [AFJSONRequestOperation
                                           JSONRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                               //
                                               // nonce call to server completed OK.
                                               NSError* error = nil;
                                               if (![JSON isKindOfClass:[NSDictionary class]])
                                               {
                                                   error = [BDFJSONAPIUserClient invalidResponseType];
                                               }
                                               else
                                               {
                                                   NSDictionary* dictionary = (NSDictionary*)JSON;
                                                   if ([dictionary[@"status"] isEqualToString:@"ok"])
                                                   {
                                                       // grab the auth_cookie for later use
                                                       weakSelf.authCookie = dictionary[@"cookie"];
                                                   }
                                                   else
                                                   {
                                                       error = [NSError errorWithDomain:BDFErrorDomain
                                                                                   code:BDFRegistrationError
                                                                               userInfo:@{NSLocalizedDescriptionKey: dictionary[@"error"]}];
                                                   }

                                               }
                                               if (completion)
                                               {
                                                   completion(weakSelf.authCookie, error);
                                               }
                                           }
                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                               if (completion)
                                               {
                                                   completion(nil, error);
                                               }
                                           }];
    [self.operationQueue addOperation:jsonRequest];
}

-(void)addParametersToUrl:(NSMutableString*)urlStr
         usingProfileData:(NSDictionary*)profileData
{
    // now add each field in turn to be updated
    for (NSString* field in profileData)
    {
        NSString* escapedField = [BDFJSONAPIUserClient percentEscapeString:field];
        NSString* escapedValue = [BDFJSONAPIUserClient percentEscapeString:profileData[field]];
        [urlStr appendFormat:@"&field_%@=%@", escapedField, escapedValue];
    }
}


-(void) updateProfileUsingAuthCookie:(NSString*)authCookie
                   withData:(NSDictionary*)profileData
             completionBlock:(BDFUserManagementCompletionBlock)completion
{
    NSMutableString* urlStr = [NSMutableString stringWithFormat:BuddyfiedUpdateProfileURL,
                               [BDFSettings sharedSettings].buddySite,
                               [BDFJSONAPIUserClient percentEscapeString:authCookie]];
    //
    [self addParametersToUrl:urlStr usingProfileData:profileData];
    //
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"POST";
    
    AFJSONRequestOperation* jsonRequest = [AFJSONRequestOperation
                                           JSONRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                               NSError* error = nil;
                                               if (![JSON isKindOfClass:[NSDictionary class]])
                                               {
                                                   error = [BDFJSONAPIUserClient invalidResponseType];
                                               }
                                               else
                                               {
                                                   NSDictionary* result = (NSDictionary*)JSON;
                                                   if (![result[@"status"] isEqualToString:@"ok"])
                                                   {
                                                       error = [NSError errorWithDomain:BDFErrorDomain
                                                                                   code:BDFRegistrationError
                                                                               userInfo:@{NSLocalizedDescriptionKey: result[@"error"]}];
                                                   }
                                               }
                                               if (completion)
                                               {   // no useful result back here, just need to recognise failure via error
                                                   
                                                   completion(nil, error);
                                               }
                                           }
                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                               if (completion)
                                               {
                                                   completion(nil, error);
                                               }
                                           }];
    [self.operationQueue addOperation:jsonRequest];
}

-(void) registerNewUserUsingNOnceToken:(NSString*)nonce
                               forUser:(NSString*)user
                          withPassword:(NSString*)password
                       andEmailAddress:(NSString*)email
                             usingData:(NSDictionary*)profileData
                       completionBlock:(BDFUserManagementCompletionBlock)completion
{
    //@"%@api/user/buddypress_register?username=%@&nonce=%@&email=%@&password=%@"
    NSString* escapedUser = [BDFJSONAPIUserClient percentEscapeString:user];
    NSMutableString* urlStr = [NSMutableString stringWithFormat:BuddyfiedRegisterUserURL,
                               [BDFSettings sharedSettings].buddySite,
                               escapedUser,
                               [BDFJSONAPIUserClient percentEscapeString:nonce],
                               [BDFJSONAPIUserClient percentEscapeString:email],
                               password];
    //
    [self addParametersToUrl:urlStr usingProfileData:profileData];
    //
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"POST";
    
    BDFJSONAPIUserClient* __weak weakSelf = self;
    AFJSONRequestOperation* jsonRequest = [AFJSONRequestOperation
                                           JSONRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                               //
                                               // call succeeded, but user registration may or may not have done.
                                               // REGISTRATION SUCCEEDED
                                               //{
                                               //  cookie = "devtestuser|1405520768|decac9d414670153b07395f4a5f95e57";
                                               //  status = ok;
                                               //  "user_id" = 35;
                                               //}
                                               //
                                               // ERROR CASES:
                                               //{
                                               //    error = "Username already exists.";
                                               //    status = error;
                                               //}
                                               //
                                               //{
                                               //    error = "E-mail address is already in use.";
                                               //    status = error;
                                               //}
                                               NSError* error = nil;
                                               NSDictionary* result = nil;
                                               if (![JSON isKindOfClass:[NSDictionary class]])
                                               {
                                                   error = [BDFJSONAPIUserClient invalidResponseType];
                                               }
                                               else
                                               {
                                                   result = (NSDictionary*)JSON;
                                                   if ([result[@"status"] isEqualToString:@"ok"])
                                                   {
                                                       // grab the auth_cookie for later use
                                                       weakSelf.authCookie = result[@"cookie"];
                                                   }
                                                   else
                                                   {
                                                       error = [NSError errorWithDomain:BDFErrorDomain
                                                                                   code:BDFRegistrationError
                                                                               userInfo:@{NSLocalizedDescriptionKey: result[@"error"]}];
                                                   }
                                               }
                                               if (completion)
                                               {
                                                   completion(result, error);
                                               }
                                           }
                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                               if (completion)
                                               {
                                                   completion(nil, error);
                                               }
                                           }];
    [self.operationQueue addOperation:jsonRequest];
}

+ (NSString *)percentEscapeString:(NSString *)string
{
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)string,
                                                                                 (CFStringRef)@" ",
                                                                                 (CFStringRef)@":/?@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

+ (NSError*) invalidResponseType
{
    return [NSError errorWithDomain:BDFErrorDomain
                               code:BDFInvalidResponseType
                           userInfo:@{NSLocalizedDescriptionKey: @"Invalid response from server"}];
}

@end
