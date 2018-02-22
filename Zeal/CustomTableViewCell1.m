//
//  CustomTableViewCell1.m
//  Zeal
//
//  Created by P1 on 6/1/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import "CustomTableViewCell1.h"

@implementation CustomTableViewCell1
@synthesize iconImageView, titleLabel, subTitleLabel;

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

@end
