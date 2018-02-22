//
//  CustomTableFinancialAccountsTableViewCell.m
//  Zeal
//
//  Created by P1 on 6/9/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import "CustomTableFinancialAccountsTableViewCell.h"

@implementation CustomTableFinancialAccountsTableViewCell

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

- (IBAction)didSelectAdd:(id)sender {
    _img_tick.hidden = NO;
    _btn_add.hidden = YES;
}

@end
