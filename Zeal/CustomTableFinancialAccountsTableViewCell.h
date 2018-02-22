//
//  CustomTableFinancialAccountsTableViewCell.h
//  Zeal
//
//  Created by P1 on 6/9/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableFinancialAccountsTableViewCell : UITableViewCell
{
    
}
@property (weak, nonatomic) IBOutlet UILabel *mLabelAccountName;
@property (weak, nonatomic) IBOutlet UILabel *minstitutionName;
@property (weak, nonatomic) IBOutlet UILabel *mAmounts;
@property (weak, nonatomic) IBOutlet UIImageView *logo_img;
@property (weak, nonatomic) IBOutlet UIImageView *logo_img_ChartView;
@property (weak, nonatomic) IBOutlet UILabel *seperator_line;
@property (weak, nonatomic) IBOutlet UIButton *btn_add;
@property (weak, nonatomic) IBOutlet UIImageView *img_tick;

@property (weak, nonatomic) IBOutlet UIView *plaid_main_list_view;
@property (weak, nonatomic) IBOutlet UIImageView *plaid_institution_logo;
@property (weak, nonatomic) IBOutlet UILabel *plaid_title;
@property (weak, nonatomic) IBOutlet UILabel *plaid_subTitle;
@end
