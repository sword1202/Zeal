//
//  CustomCellForCoffeeTableViewCell.h
//  Zeal
//
//  Created by P1 on 8/18/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCellForCoffeeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *orderView;
@property (weak, nonatomic) IBOutlet UIImageView *smallImageView;
@property (weak, nonatomic) IBOutlet UIImageView *mediumImageView;
@property (weak, nonatomic) IBOutlet UIImageView *largeImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *historyView;
@property (weak, nonatomic) IBOutlet UIImageView *img_tickOfOrder;
@property (weak, nonatomic) IBOutlet UILabel *icon_detali_label;
@property (weak, nonatomic) IBOutlet UILabel *avr_spendAmount;
@property (weak, nonatomic) IBOutlet UILabel *numberOfVisit;
@property (weak, nonatomic) IBOutlet UIView *orderView2;
@property (weak, nonatomic) IBOutlet UILabel *order2_title;
@property (weak, nonatomic) IBOutlet UILabel *order2_detail;
@end
