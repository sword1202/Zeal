//
//  CoffeeObj.h
//  Zeal
//
//  Created by P1 on 2/21/18.
//  Copyright © 2018 ZealOfCnorth2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoffeeObj : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * location_id;
@property (nonatomic, strong) NSString * imgName;
@property (nonatomic, strong) NSArray  * orderLists;

-(instancetype)initWithDic:(NSDictionary *)dic;
-(NSDictionary *)dicObject;

@end
