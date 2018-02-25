//
//  CommonUtils.h
//  Zeal
//
//  Created by P1 on 2/20/18.
//  Copyright © 2018 ZealOfCnorth2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtils : NSObject

+(BOOL)isNull:(id )value;
+(NSString *)getAmountFromDic:(NSDictionary *) object key: (NSString *) key;
+ (NSString *) getMonthKey: (NSString *) mString;
+ (NSString *) randomString;

@end
