//
//  MerchantShops.h
//  Zeal
//
//  Created by P1 on 5/29/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MerchantShops : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray  *arrayForBoolOrder, *arrForBoolHistory;
    int logoState;
}
@property (weak, nonatomic) IBOutlet UITableView *table_view;

@end
