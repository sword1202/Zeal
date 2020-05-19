//
//  TransactionsCellTableViewCell.m
//  Zeal
//
//  Created by mappexpert on 5/19/20.
//  Copyright © 2020 ZealOfCnorth2. All rights reserved.
//

#import "TransactionsCellTableViewCell.h"

@implementation TransactionsCellTableViewCell

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
    [super setSelected:selected animated:NO];

    // Configure the view for the selected state
}

- (IBAction)didSelectAdd:(UIButton *)sender {
}
@end
