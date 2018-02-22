//
//  MerchantAccountRateReviewsViewController.h
//  Zeal
//
//  Created by P1 on 6/5/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface MerchantAccountRateReviewsViewController : UIViewController <UITextViewDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UIButton *btn_rate;
@property (nonatomic, retain) MBProgressHUD *hud;
@property (weak, nonatomic) AppDelegate *app;
@end
