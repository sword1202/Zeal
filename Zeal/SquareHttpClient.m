//
//  SquareHttpClient.m
//  Zeal
//
//  Created by P1 on 2/21/18.
//  Copyright © 2018 ZealOfCnorth2. All rights reserved.
//

#import "SquareHttpClient.h"

@implementation SquareHttpClient
+ (SquareHttpClient *)sharedSquareHttpClient
{
    static SquareHttpClient *_sharedSquareHttpClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      _sharedSquareHttpClient = [[self alloc] initWithBaseURL: [NSURL URLWithString: kSquareupBaseURL]];
                      [_sharedSquareHttpClient.requestSerializer setValue:@"application/json" forHTTPHeaderField: @"Content-Type"];
                      [_sharedSquareHttpClient.requestSerializer setValue:[NSString stringWithFormat: @"Bearer %@", ACCESSTOKEN_SQUAREUP] forHTTPHeaderField: @"Authorization"];
                  });
    return _sharedSquareHttpClient;
}

- (void) downloadSquareupItemsWithCompletionHandler: (void(^)(NSArray * items))handler
{
    [self GET: @"/v2/catalog/list?types=item"
   parameters: nil
      success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         NSArray *sortedCatalogs = [(NSDictionary *)responseObject objectForKey: @"objects"];
         handler(sortedCatalogs);
     }
      failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         NSLog(@"Failed to retrieve Square Catalogs: %@", error.localizedDescription);
     }];
}

- (void) downloadSquareupCategoryWithCompletionHandler: (void(^)(NSArray * items))handler
{
    [self GET: @"/v2/catalog/list?types=category"
   parameters: nil
      success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         NSArray *sortedCatalogs = [(NSDictionary *)responseObject objectForKey: @"objects"];
         handler(sortedCatalogs);
     }
      failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         NSLog(@"Failed to retrieve Square Catalogs: %@", error.localizedDescription);
     }];
}

@end
