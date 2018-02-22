//
//  SquareHttpClient.h
//  Zeal
//
//  Created by P1 on 2/21/18.
//  Copyright © 2018 ZealOfCnorth2. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface SquareHttpClient : AFHTTPSessionManager

+ (SquareHttpClient *)sharedSquareHttpClient;

// download item of catalog
- (void) downloadSquareupItemsWithCompletionHandler: (void(^)(NSArray * items))handler;

// download category of catalog
- (void) downloadSquareupCategoryWithCompletionHandler: (void(^)(NSArray * items))handler;

@end
