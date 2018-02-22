//
//  CommonUtils.m
//  Zeal
//
//  Created by P1 on 2/20/18.
//  Copyright © 2018 ZealOfCnorth2. All rights reserved.
//

#import "CommonUtils.h"

@implementation CommonUtils

+(BOOL)isNull:(id )value{
    
    if (value != nil && ![value isEqual:[NSNull null]]) {
        return NO;
    }
    return YES;
}

+(NSString *)getAmountFromDic:(NSDictionary *) object key: (NSString *) key {
    
    if ([[object objectForKey: key] stringValue] == nil) {
        return @"0";
    } else {
        float kIntValue = [[object objectForKey: key] floatValue];
        kIntValue/=1000;
        return [NSString stringWithFormat: @"%lf", kIntValue];
    }
    
    
}

+ (NSString *) getMonthKey: (NSString *) mString
{
    NSString *str = @"";
    if ([mString isEqualToString: @"01"]) {
        str = @"Jan";
    } else if ([mString isEqualToString: @"02"]) {
        str = @"Feb";
    } else if ([mString isEqualToString: @"03"]) {
        str = @"Mar";
    } else if ([mString isEqualToString: @"04"]) {
        str = @"Apr";
    } else if ([mString isEqualToString: @"05"]) {
        str = @"May";
    } else if ([mString isEqualToString: @"06"]) {
        str = @"Jun";
    } else if ([mString isEqualToString: @"07"]) {
        str = @"Jul";
    } else if ([mString isEqualToString: @"08"]) {
        str = @"Aug";
    } else if ([mString isEqualToString: @"09"]) {
        str = @"Sep";
    } else if ([mString isEqualToString: @"10"]) {
        str = @"Oct";
    } else if ([mString isEqualToString: @"11"]) {
        str = @"Nov";
    } else if ([mString isEqualToString: @"12"]) {
        str = @"Dec";
    }
    return str;
}

@end
