//
//  ReorderTableCell.h
//  Zeal
//
//  Created by mappexpert on 5/19/20.
//  Copyright © 2020 ZealOfCnorth2. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReorderTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *removeImageView;
@property (weak, nonatomic) IBOutlet UILabel *countOrder;
@property (weak, nonatomic) IBOutlet UILabel *orderName;
@property (weak, nonatomic) IBOutlet UILabel *orderAmount;

@end

NS_ASSUME_NONNULL_END
