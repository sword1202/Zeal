//
//  CustomTableViewCell2.m
//  Zeal
//
//  Created by P1 on 6/1/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import "CustomTableViewCell2.h"
#import "AppDelegate.h"

@implementation CustomTableViewCell2
@synthesize iconImageView, titleLabel, plus_button, mainViewController, subTitleLabel;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didSelectPlusButton:(id)sender {
    UIButton *button = (UIButton *) sender;
    NSLog(@"plus---%d",(int)button.tag);
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.feedbackAddButtonAndBackButtonFlag = false;
    if (button.tag >= 100 && button.tag < 200) {
        // Home
        app.indexOfSelectedImageOfMerchantAccount = (int)button.tag - 100;
        app.isSelectedPlusButtonForHome = 0;
    } else if (button.tag >= 200 && button.tag < 300)
    {
        // Pharamacy
        app.indexOfSelectedImageOfMerchantAccount = (int)button.tag - 200;
        app.isSelectedPlusButtonForHome = 1;
    } else if (button.tag >= 300)
    {
        // Coffee
        app.indexOfSelectedImageOfMerchantAccount = (int)button.tag - 300;
        app.isSelectedPlusButtonForHome = 2;
    }
    
    [[NSNotificationCenter defaultCenter] 
        postNotificationName:@"AddButtonPressed"
        object:self];

}
@end
