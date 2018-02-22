//
//  CustomTableViewCell2.h
//  Zeal
//
//  Created by P1 on 6/1/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "AppDelegate.h"
#import "HCSStarRatingView.h"

@interface CustomTableViewCell2 : UITableViewCell
{
    AppDelegate *app;
}
@property (nonatomic, retain) MainViewController *mainViewController;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel_noReview;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel_noReview;
@property (weak, nonatomic) IBOutlet UIButton *plus_button;
- (IBAction)didSelectPlusButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *ratingView;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *vipHCStarRatingView;
@property (weak, nonatomic) IBOutlet UILabel *historyLabel;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *productHCStarRatingView;
@end
