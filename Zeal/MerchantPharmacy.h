//
//  MerchantPharmacy.h
//  Zeal
//
//  Created by P1 on 5/29/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MerchantPharmacy : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    __weak IBOutlet UIButton *btn_addMore;
    
}
@property (weak, nonatomic) IBOutlet UITableView *table_view;
- (IBAction)didSelectAddMorePrograms:(id)sender;

@end
