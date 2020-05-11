//
//  MerchantAccountCoffee.h
//  Zeal
//
//  Created by P1 on 7/4/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    SMALL = 0,
    MEDIUM,
    LARGE,
};

@interface MerchantAccountCoffee : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
    NSMutableArray  *arrayForBoolOrder, *arrForBoolHistory;
    NSArray *cellNameArrayOfOrder, *cellNameArrayOfHistory;
    int logoState;
}

@property (weak, nonatomic) IBOutlet UITableView *table_view;

@end
