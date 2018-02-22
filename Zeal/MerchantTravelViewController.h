//
//  MerchantTravelViewController.h
//  Zeal
//
//  Created by P1 on 11/23/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MerchantTravelViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray  *arrayForBoolOrder, *arrForBoolHistory;
    NSArray *cellNameArrayOfOrder, *cellNameArrayOfHistory;
    int logoState;
}
@property (weak, nonatomic) IBOutlet UITableView *table_view;

@end
