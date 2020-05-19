//
//  TransactionsCellTableViewCell.h
//  Zeal
//
//  Created by mappexpert on 5/19/20.
//  Copyright © 2020 ZealOfCnorth2. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TransactionsCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *officialname_label;
@property (weak, nonatomic) IBOutlet UILabel *amount_label;
@property (weak, nonatomic) IBOutlet UIButton *btn_reorder;

@end

NS_ASSUME_NONNULL_END
