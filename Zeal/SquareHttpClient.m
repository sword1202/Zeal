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
         NSArray *sortedItems = [(NSDictionary *)responseObject objectForKey: @"objects"];
         handler(sortedItems);
     }
      failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         NSLog(@"Failed to retrieve Square Items: %@", error.localizedDescription);
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

- (void) getLocationsFromSquareup: (void(^)(NSArray * items))handler
{
    [self GET: @"/v2/locations"
   parameters: nil
      success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         NSArray *sortedLocations = [(NSDictionary *)responseObject objectForKey: @"locations"];
         handler(sortedLocations);
     }
      failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         NSLog(@"Failed to retrieve Square Locations: %@", error.localizedDescription);
     }];
}

- (void) createOrderwithlocationid: (NSString *) location_id catalog_obj_id: (NSString *) catalog_obj_id
                        withCompletionHandler: (void(^)(NSInteger responseCode, NSArray *transactions))handler
{
    NSDictionary *variationItem = @{
                                    @"catalog_object_id": catalog_obj_id,
                                    @"quantity"        : @"2"
                                    };
    
    NSDictionary *requestParameters = @{
                                        @"idempotency_key"     : [CommonUtils randomString],
                                        @"line_items"          : [NSArray arrayWithObjects: variationItem, nil]
                                        };
    
    [self POST:[NSString stringWithFormat: @"/v2/locations/%@/orders", location_id] parameters:requestParameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSArray *accountsArray = (NSArray *)responseObject[@"order"];
        handler(response.statusCode, accountsArray);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        handler(response.statusCode, nil);
    }];
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
