//
//  CoffeeObj.m
//  Zeal
//
//  Created by P1 on 2/21/18.
//  Copyright © 2018 ZealOfCnorth2. All rights reserved.
//

#import "CoffeeObj.h"

@implementation CoffeeObj
-(instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    
    if (self) {
        
        if (dic == nil) {
            return [[CoffeeObj alloc] init];
        }
        self.name = dic[kcategoryName];
        self.location_id = [CommonUtils isNull: dic[klocationID]] ? @"":dic[klocationID];
        self.imgName = dic[kImageName];
        self.orderLists = [CommonUtils isNull: dic[kOrderLists]] ? [[NSArray alloc] init]:dic[kOrderLists];
    }
    
    return self;
    
}

-(NSDictionary *)dicObject {
    NSDictionary * dic = @{
                           kcategoryName:self.name,
                           klocationID:self.location_id,
                           kImageName:self.imgName,
                           kOrderLists:self.orderLists
                           };
    return dic;
}

@end
