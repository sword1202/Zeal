//
//  PlaidHTTPClient.m
//  EnvelopeBudget
//
//  Created by Nate on 5/29/14.
//  Copyright (c) 2014 Nate. All rights reserved.
//

#import "PlaidHTTPClient.h"
#define CLIENT_ID @"58d1aeaebdc6a40edcf7d6a2"
#define SECRET_KEY @"aac96375598281ae37438360142b74"
#define header @{@"Content-Type":@"application/json"}

@interface PlaidHTTPClient ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end



@implementation PlaidHTTPClient


#pragma mark - Setters & Getters

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter)
    {
        _dateFormatter = [NSDateFormatter new];
        [_dateFormatter setLocale: [NSLocale localeWithLocaleIdentifier: @"en_US_PSIX"]];
        [_dateFormatter setDateFormat: @"yyy-MM-dd"];
    }
    return _dateFormatter;
}



#pragma mark - Public Class Methods

+ (PlaidHTTPClient *)sharedPlaidHTTPClient;
{
    static PlaidHTTPClient *_sharedPlaidHTTPClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                              {
                                  _sharedPlaidHTTPClient = [[self alloc] initWithBaseURL: [NSURL URLWithString: kPlaidBaseURL]];
                              });
    return _sharedPlaidHTTPClient;
}



#pragma mark - Public Instance Methods

- (void) downloadPlaidInstitutionsWithCompletionHandler: (void(^)(NSArray * institutions))handler
{
    [self GET:@"/institutions" parameters:nil headers:header progress:nil success:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSArray *sortedInstitutions = [(NSArray *)responseObject sortedArrayUsingDescriptors: @[[[NSSortDescriptor alloc] initWithKey: @"name"
                                                                                                                            ascending: YES]]];
        handler(sortedInstitutions);
    } failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        NSLog(@"Failed to retrieve Plaid institutions: %@", error.localizedDescription);
    }];
}

- (void) getAccessTokenWithCompletionHandler: (NSString *)publickToken
                       withCompletionHandler: (void(^)(NSInteger responseCode, NSDictionary *responseObj))handler
{
    NSDictionary *requestParameters = @{@"client_id"  : CLIENT_ID,
                                      @"secret"     : SECRET_KEY,
                                      @"public_token": publickToken};
    
    [self POST:@"/item/public_token/exchange" parameters:requestParameters headers: header progress:nil success:^(NSURLSessionDataTask *task, id responseObject)
    {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        
        handler(response.statusCode, responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSLog(@"Failed to retrieve AccessToken Response: %@", error.localizedDescription);
        
        handler(response.statusCode, nil);
    }];
}



- (void) loginToInstitution: (NSString *)institutionType
                   userName: (NSString *)userName
                   password: (NSString *)password
                        pin: (NSString *)pin
                      email: (NSString *)email
      withCompletionHandler: (void(^)(NSInteger responseCode, NSDictionary *userAccounts))handler
{
//    NSDictionary *credentials     = @{@"username": userName,
//                                      @"password": password,
//                                      @"pin"     : pin};
//    
//    NSDictionary *logInParameters = @{@"client_id"  : CLIENT_ID,
//                                      @"secret"     : SECRET_KEY,
//                                      @"credentials": credentials,
//                                      @"type"       : institutionType,
//                                      @"email"      :email};
//    
//    [self POST: @"/connect"
//    parameters: logInParameters
//       success: ^(NSURLSessionDataTask *task, id responseObject)
//                {
//                    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
//                    
//                    handler(response.statusCode, responseObject);
//                    
//                }
//       failure: ^(NSURLSessionDataTask *task, NSError *error)
//                {
//                    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
//                    NSLog(@"Unable to login into account with response code : %ld.  Error: %@", (long)response.statusCode, error.localizedDescription);
//                    
//                    handler(response.statusCode, nil);
//                }];
}



- (void) submitMFAResponse: (NSString *)mfaResponse
               institution: (NSString *)institutionType
               accessToken: (NSString *)accessToken
     withCompletionHandler: (void(^)(NSInteger responseCode, NSDictionary *userAccounts))handler
{
//    NSDictionary *mfaParameters = @{@"client_id"    : CLIENT_ID,
//                                    @"secret"       : SECRET_KEY,
//                                    @"mfa"          : mfaResponse,
//                                    @"access_token" : accessToken,
//                                    @"type"         : institutionType};
//    
//    [self POST: @"/connect/step"
//    parameters: mfaParameters
//       success: ^(NSURLSessionDataTask *task, id responseObject)
//     {
//         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
//         
//         handler(response.statusCode, responseObject);
//     }
//       failure: ^(NSURLSessionDataTask *task, NSError *error)
//     {
//         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
//         NSLog(@"Unable to login into account with response code : %ld.  Error: %@", (long)response.statusCode, error.localizedDescription);
//         
//         handler(response.statusCode, nil);
//     }];
}



- (void) downloadTransactionsForAccessToken: (NSString *)accessToken
                                        fromDate: (NSString *)fromDate
                                        toDate: (NSString *)toDate
                                    withCompletionHandler: (void(^)(NSInteger responseCode, NSArray *transactions))handler
{
    
    NSDictionary *requestParameters = @{
                                         @"client_id"     : CLIENT_ID,
                                         @"secret"        : SECRET_KEY,
                                         @"access_token"  : accessToken,
                                         @"start_date"    : fromDate,
                                         @"end_date"      : toDate
                                         };
    
//    [self POST: @"/transactions/get"
//   parameters: requestParameters
//      success: ^(NSURLSessionDataTask *task, id responseObject)
//     {
//         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
//         NSArray *transactionsArray = (NSArray *)responseObject[@"transactions"];
//         handler(response.statusCode, transactionsArray);
//     }
//      failure: ^(NSURLSessionDataTask *task, NSError *error)
//     {
//         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
//         handler(response.statusCode, nil);
//     }];
    [self POST:@"/transactions/get" parameters:requestParameters headers:header progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSArray *transactionsArray = (NSArray *)responseObject[@"transactions"];
        handler(response.statusCode, transactionsArray);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        handler(response.statusCode, nil);
    }];
}



- (void) downloadAccountDetailsForAccessToken: (NSString *)accessToken
                      withCompletionHandler: (void(^)(NSInteger responseCode, NSArray *transactions))handler
{
    
    NSDictionary *requestParameters = @{
                                        @"client_id"     : CLIENT_ID,
                                        @"secret"        : SECRET_KEY,
                                        @"access_token"  : accessToken
                                        };
    [self POST:@"/accounts/get" parameters:requestParameters headers:header progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSArray *accountsArray = (NSArray *)responseObject[@"accounts"];
        handler(response.statusCode, accountsArray);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        handler(response.statusCode, nil);
    }];
}



- (void)downloadPlaidEntity: (NSString *)entityID
                    success: (void(^)(NSURLSessionDataTask *task, id plaidEntity))success
                    failure: (void(^)(NSURLSessionDataTask *task, NSError *error))failure
{
//    [self GET: [NSString stringWithFormat: @"/entities/%@", entityID]
//   parameters: nil
//      success: ^(NSURLSessionDataTask *task, id responseObject)
//               {
//                   success(task, responseObject);
//               }
//      failure: ^(NSURLSessionDataTask *task, NSError *error)
//               {
//                   failure(task, error);
//               }];
}



#pragma mark - Private Methods

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL: url];
    
    if (self)
    {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer  = [AFJSONRequestSerializer serializer];
    }
    return self;
}


@end
