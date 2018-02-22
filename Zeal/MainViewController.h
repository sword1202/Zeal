//
//  MainViewController.h
//  Zeal
//
//  Created by P1 on 5/25/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarChartView.h"
#import "BEMSimpleLineGraphView.h"
//@import FBSDKLoginKit;
//@import FBSDKCoreKit;

@interface MainViewController : UIViewController <UINavigationControllerDelegate, UIWebViewDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>
{
    
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIWebView *webViewAbout;
    
    // profile params
    __weak IBOutlet UILabel *userid;
    __weak IBOutlet UILabel *userName;
    __weak IBOutlet UILabel *userEmail;
    
    
    __weak IBOutlet UITableView *table_view;
    
    // MerchantAccounts page params
    
    __weak IBOutlet UIScrollView *mScrollViewMerchantAccounts;
    __weak IBOutlet UIView *merchantAccountFeedbackView;
    
    
}
@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *myGraph;
@property (strong, nonatomic) NSMutableArray *arrayOfValues;
@property (strong, nonatomic) NSMutableArray *arrayOfDates;

@property (strong, nonatomic) IBOutlet UILabel *labelValues;
@property (strong, nonatomic) IBOutlet UILabel *labelDates;

@property (weak, nonatomic) IBOutlet UIView *merchantAccountsView;
@property (weak, nonatomic) IBOutlet UIView *financialAccountsView;
@property (weak, nonatomic) IBOutlet UIView *aboutView;

// MerchantAccounts
- (IBAction)didSelectPhamacy:(id)sender;


@end
