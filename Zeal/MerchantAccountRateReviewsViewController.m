//
//  MerchantAccountRateReviewsViewController.m
//  Zeal
//
//  Created by P1 on 6/5/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import "MerchantAccountRateReviewsViewController.h"
#import "HCSStarRatingView.h"
#import "UIViewController+Alerts.h"

#define PRODUCT_KEY @"Product Discounts"
#define VIP_KEY @"VIP Service"
#define OTHER_KEY @"Other Services"

@import Firebase;

@interface MerchantAccountRateReviewsViewController ()
{
    __weak IBOutlet HCSStarRatingView *productRateView;
    __weak IBOutlet HCSStarRatingView *vipRateView;
    __weak IBOutlet HCSStarRatingView *otherRate;
    __weak IBOutlet UITextView *tv_comments;
    
    __weak IBOutlet UIView *bodyView;
    __weak IBOutlet UIView *productDiscountsView;
    __weak IBOutlet UIView *vipServiceView;
    __weak IBOutlet UIView *otherServicesView;
    __weak IBOutlet UIImageView *iv_merchantAccountsLogo;
    __weak IBOutlet UILabel *lb_title;
    NSArray *arr_ImageNames;
    
    FIRDatabaseReference *mFirebaseDBReference;
    
    NSString *rateVIP, *rateProducService, *rateOther;
    
    __weak IBOutlet UILabel *subtitleNameLabel;
}
@end

@implementation MerchantAccountRateReviewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *userID = [[[FIRAuth auth] currentUser] uid];
    
    self.app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSDictionary *selectedAccounts;
    
    if (!self.app.isSelectedPlusButtonForHome) {
        // Pharmacy
        selectedAccounts = [self.app.arr_pharmacy_merchantAccounts objectAtIndex: self.app.indexOfSelectedImageOfMerchantAccount];
        iv_merchantAccountsLogo.image = [UIImage imageNamed: [selectedAccounts objectForKey: @"img_name"]];
        lb_title.text = [selectedAccounts objectForKey: @"title_name"];
        mFirebaseDBReference = [[[[[FIRDatabase database] reference] child: userID] child: @"rate_db_pharmacy"] child:lb_title.text];
        subtitleNameLabel.text = @"Pharmacy";
    } else
    {
        // Home
        selectedAccounts = [self.app.arr_home_merchantAccounts objectAtIndex: self.app.indexOfSelectedImageOfMerchantAccount];
        iv_merchantAccountsLogo.image = [UIImage imageNamed: [selectedAccounts objectForKey: @"img_name"]];
        lb_title.text = [selectedAccounts objectForKey: @"title_name"];
        mFirebaseDBReference = [[[[[FIRDatabase database] reference] child: userID] child: @"rate_db_home"] child:lb_title.text];
        subtitleNameLabel.text = @"Home";
    }
    
    [self retrieveDB];
//    [self drawBorderOfTextView];
//    [self drawBorder];
    
}

- (void) retrieveDB
{
    
    if (mFirebaseDBReference != nil) {
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        self.hud.label.text = @"Downloading...";
        
        [mFirebaseDBReference observeSingleEventOfType:(FIRDataEventTypeValue) withBlock: ^(FIRDataSnapshot *_Nonnull snapshot) {
            self.hud.hidden = YES;
            if ([snapshot exists]) {
                NSDictionary *dic = snapshot.value;
                rateProducService = [dic objectForKey: PRODUCT_KEY];
                rateVIP = [dic objectForKey: VIP_KEY];
                rateOther = [dic objectForKey: OTHER_KEY];
                productRateView.value = [rateProducService floatValue];
                vipRateView.value = [rateVIP floatValue];
                otherRate.value = [rateOther floatValue];
                
                self.btn_rate.enabled = YES;
                [self.btn_rate setBackgroundColor: [UIColor colorWithRed:120.0f/255.0f green:165.0f/255.0f  blue:163.0f/255.0f  alpha:1.0]];
            } else
            {
                productRateView.value = 0.0f;
                vipRateView.value = 0.0f;
                otherRate.value = 0.0f;
                
                self.btn_rate.enabled = NO;
                [self.btn_rate setBackgroundColor: [UIColor lightGrayColor]];
            }
        }];
        
    } else
    {
        productRateView.value = 0.0f;
        vipRateView.value = 0.0f;
        otherRate.value = 0.0f;
        
        self.btn_rate.enabled = NO;
        [self.btn_rate setBackgroundColor: [UIColor lightGrayColor]];
    }
}

- (void) drawBorderOfTextView
{
    UIColor *borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];

    tv_comments.layer.borderColor = borderColor.CGColor;
    tv_comments.layer.borderWidth = 1.0;
    tv_comments.layer.cornerRadius = 8.0;

}

- (void) drawBorder
{
    UIColor *borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    
    bodyView.layer.borderColor = borderColor.CGColor;
    bodyView.layer.borderWidth = 1.0;
    bodyView.layer.cornerRadius = 15.0;
    
    //
    productDiscountsView.layer.borderColor = borderColor.CGColor;
    productDiscountsView.layer.borderWidth = 1.0;
    productDiscountsView.layer.cornerRadius = 5.0;
    
    //
    vipServiceView.layer.borderColor = borderColor.CGColor;
    vipServiceView.layer.borderWidth = 1.0;
    vipServiceView.layer.cornerRadius = 5.0;
    
    //
    otherServicesView.layer.borderColor = borderColor.CGColor;
    otherServicesView.layer.borderWidth = 1.0;
    otherServicesView.layer.cornerRadius = 5.0;
}

#pragma mark TextView PlaceHoler
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if (tv_comments.textColor == [UIColor lightGrayColor]) {
        tv_comments.text = @"";
        tv_comments.textColor = [UIColor blackColor];
    }
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(tv_comments.text.length == 0){
        tv_comments.textColor = [UIColor lightGrayColor];
        tv_comments.text = @"Please leave your comments here.";
        [tv_comments resignFirstResponder];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if(tv_comments.text.length == 0){
            tv_comments.textColor = [UIColor lightGrayColor];
            tv_comments.text = @"Please leave your comments here.";
            [tv_comments resignFirstResponder];
        }
        return NO;
    }
    
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didSelectBack:(id)sender {
    
    // return Merchant Account page if stored data on DB successfully
    self.btn_rate.userInteractionEnabled = NO;
    
    NSDictionary *saveValue = [NSDictionary dictionaryWithObjectsAndKeys: rateProducService, PRODUCT_KEY,
                                rateVIP, VIP_KEY,
                               rateOther, OTHER_KEY, nil];
    
    __weak typeof(self) weakSelf = self;
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.label.text = @"Storing...";
    
    [mFirebaseDBReference setValue: saveValue withCompletionBlock:^(NSError *_Nullable error, FIRDatabaseReference *_Nonnull ref) {
        
        weakSelf.hud.hidden = YES;
        weakSelf.btn_rate.userInteractionEnabled = YES;
        if (error) {
            [weakSelf showMessagePrompt: error.localizedDescription];
        } else
        {
            weakSelf.app.feedbackAddButtonAndBackButtonFlag = true;
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"AddButtonPressed"
             object:weakSelf];
        }
    }];
    
    
    
}

- (IBAction)didChangeRateValue:(id)sender {
    HCSStarRatingView *selectedRateView = (HCSStarRatingView *) sender;
    if (selectedRateView.value < 1.0f) {
        selectedRateView.value = 1.0f;
    }
    switch (selectedRateView.tag) {
        case 1:
            
            rateProducService = [[NSNumber numberWithFloat:selectedRateView.value] stringValue];
            NSLog(@"Product --- %@", rateProducService);
            break;
            
        case 2:
            rateVIP = [[NSNumber numberWithFloat:selectedRateView.value] stringValue];
            NSLog(@"VIP --- %@", rateVIP);
            break;
            
        case 3:
            rateOther = [[NSNumber numberWithFloat:selectedRateView.value] stringValue];
            NSLog(@"Other --- %@", rateOther);
            break;
            
        default:
            break;
    }
    
    if (rateVIP != nil && rateProducService != nil && rateOther != nil) {
        self.btn_rate.enabled = YES;
        [self.btn_rate setBackgroundColor: [UIColor colorWithRed:120.0f/255.0f green:165.0f/255.0f  blue:163.0f/255.0f  alpha:1.0]];
    }
}

@end
