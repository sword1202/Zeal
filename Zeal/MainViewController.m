//
//  MainViewController.m
//  Zeal
//
//  Created by P1 on 5/25/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import "MainViewController.h"
#import "UIViewController+Alerts.h"
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "PlaidAPIViewController.h"
#import "MerchantShops.h"
#import "MerchantEating.h"
#import "MerchantTravelViewController.h"
#import "MerchantAccountCoffee.h"
#import "MerchantAccountRateReviewsViewController.h"
#import "MFSideMenu.h"
#import "CustomTableFinancialAccountsTableViewCell.h"
//@import FBSDKCoreKit;
@import GoogleSignIn;
//
//// <!-- SMARTDOWN_PROTOCOL -->
//@interface MainViewController (PLKPlaidLinkViewDelegate) <PLKPlaidLinkViewDelegate>
//@end
//// <!-- SMARTDOWN_PROTOCOL -->

@interface MainViewController ()
{
    bool menuFlag, profileFlag, merchantAccountsFlag, financialAccountsFlag, aboutFlag, testButtonFlag;
    // profileView
    __weak IBOutlet UILabel *privacyPolicyLabel;
    __weak IBOutlet UILabel *feedbackLabel;
    
    __weak IBOutlet UIView *bottomLabelView;
    
    NSArray *shopperCategoriesAmounts;
    NSMutableArray *arrForLineGraphData, *arrForLineGraphDataLastMonth;
    NSArray *arrayItems;
    __weak IBOutlet UIView *transactionView;
    
    __weak IBOutlet UILabel *mVerticalTextLabel;
    
    // Merchant Accounts View
    
    __weak IBOutlet UIButton *mEatingButton;
    __weak IBOutlet UIButton *mShopsButton;
    __weak IBOutlet UIButton *mCoffeeButton;
    __weak IBOutlet UIButton *mTravelButton;
    CGFloat currentX, offSetX;
    MerchantAccountRateReviewsViewController *mFeedbackView;
    
    // Financial Accounts View
    
    MBProgressHUD *hud;
    NSString *mUserName, *mUserEmail, *mUserID, *currentEmail;
    AppDelegate *app;
    
    MerchantShops *mMerchantShops;
    MerchantEating *mMerchantEating;
    MerchantAccountCoffee *mMerchantCoffee;
    MerchantTravelViewController *mMerchantTravel;
    
    CGRect oldScrollviewFrame;
    NSData *mData;
}
@end

@implementation MainViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveNotification:)
                                                 name:@"PLDPlaidLinkSetupFinished"
                                               object:nil];
}

- (void)didReceiveNotification:(NSNotification*)notification {
    if ([@"PLDPlaidLinkSetupFinished" isEqualToString:notification.name]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:notification.name
                                                      object:self];
//        self.button.enabled = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *userID = [[[FIRAuth auth] currentUser] uid];
//    NSString *userName = [[[FIRAuth auth] currentUser] email];
    
    if ([userDefaults objectForKey: @"authcredential_idToken"] == nil && [userDefaults objectForKey: @"authcredential_accessToken"] == nil) {
        LoginViewController *main = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
        [self.navigationController pushViewController:main animated:NO];
        return;
    } else
    {
        
        app = (AppDelegate *) [UIApplication sharedApplication].delegate;
        [self handleWithUserLoggedInFB];
        
        
    }
    
}

- (void) handleWithUserLoggedInFB
{
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};

    [[self.navigationController navigationBar] setBarTintColor: [UIColor colorWithRed:120.0f/255.0f green:165.0f/255.0f  blue:163.0f/255.0f  alpha:1.0]];
    
    // add left bar button
    UIImage *myImage = [UIImage imageNamed:@"menu_icon"];
    myImage = [myImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:myImage style:UIBarButtonItemStylePlain target:self action:@selector(didSelectMenu:)];
    self.navigationItem.leftBarButtonItem = menuButton;
    
    // add right logo in navigation bar
    UIImage *rightLogoImage = [UIImage imageNamed: @"right_logo"];
    rightLogoImage = [rightLogoImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightIcon = [[UIBarButtonItem alloc] initWithImage:rightLogoImage style:UIBarButtonItemStylePlain target:self action: nil];
    self.navigationItem.rightBarButtonItem = rightIcon;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    menuFlag = true;
    profileFlag = true;
    merchantAccountsFlag = false;
    financialAccountsFlag = false;
    aboutFlag = false;
    
    _profileView.hidden = NO;
    _merchantAccountsView.hidden = YES;
    _financialAccountsView.hidden = YES;
    _aboutView.hidden = YES;
    
    [self labelBaseLineCreate];
    
    // initialize webview for about page
    
    NSString *path = [[NSBundle mainBundle] pathForResource: @"about_text" ofType: @"html"];
    
    [webViewAbout loadRequest: [NSURLRequest requestWithURL: [NSURL fileURLWithPath: path isDirectory: NO]]];
    
    [self getGoogleProfile]; // from Google
    
    self.profileView.hidden = YES;
    self.financialAccountsView.hidden = YES;
    self.merchantAccountsView.hidden = YES;
    self.aboutView.hidden = YES;
    
    switch (app.indexOfSelectedMenu) {
        case 1:
            // goto PROFILE VIEW
            if (mData != nil) {
                [self initProfilePage];
                self.title = [[app.menuItems objectAtIndex: 1] objectForKey: @"name"];
                self.profileView.hidden = NO;
            }
            break;
        case 2:
            // goto MERCHANT ACCOUNTS VIEW
            self.title = [[app.menuItems objectAtIndex: 2] objectForKey: @"name"];
            self.merchantAccountsView.hidden = NO;
            [self initMerchantAccountsScrollView];
            break;
        case 3:
            // goto FINANCIAL ACCOUNTS VIEW
            self.title = [[app.menuItems objectAtIndex: 3] objectForKey: @"name"];
            self.financialAccountsView.hidden = NO;
            [self addPlaidAPIViewController];
            break;
        case 4:
            // goto ABOUT VIEW
            self.title = [[app.menuItems objectAtIndex: 4] objectForKey: @"name"];
            self.aboutView.hidden = NO;
            break;
            
        default:
            break;
    }
    
}

- (IBAction)didSelectMerchantLoyalty:(id)sender {
    app.indexOfSelectedMenu = 2;
    [self viewWillAppear: NO];
}

- (IBAction)didSelectFinancePage:(id)sender {
    app.indexOfSelectedMenu = 3;
    [self viewWillAppear: NO];
}

- (void) getGoogleProfile
{
    mUserID = app.mUserID;
    mUserName = app.mUserName;
    mUserEmail =app.mUserEmail;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    mData = [userDefaults objectForKey: @"facebook_logo_data"];
    if (mData == nil) {
        app.onceInitFlag = true;
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"Loading...";
        
        // get profile from Google Signin
        mUserName = [[[FIRAuth auth] currentUser] displayName];
        currentEmail = [[[FIRAuth auth] currentUser] email];
        mUserID = [[[FIRAuth auth] currentUser] uid];
        
        app.mUserName = mUserName;
        app.mUserEmail = currentEmail;
        app.mUserID = mUserID;
        
        // store full name on db
        FIRDatabaseReference *dbRef = [[FIRDatabase database] reference];
        NSString *userID = [[[FIRAuth auth] currentUser] uid];
        //    userID = @"EGSKXZWM3COl253jke9bi5eCzSI3";
        [[[dbRef child:userID] child: @"name"] setValue: mUserName];
//        [userName setText: [@"Name  : " stringByAppendingString: mUserName]];
//        [userid setText: [  @"UserID: " stringByAppendingString: mUserID]];
//        [userEmail setText: [@"Email : " stringByAppendingString: currentEmail]];
        
        if ([[GIDSignIn sharedInstance] currentUser] != nil && [[[[GIDSignIn sharedInstance] currentUser] profile] hasImage]) {
            NSURL *imageURL = [[[[GIDSignIn sharedInstance] currentUser] profile] imageURLWithDimension: 100];
            
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSData *data = [NSData dataWithContentsOfURL:imageURL];
                if ( data == nil )
                    return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    // WARNING: is the cell still using the same data by this point??
                    app.mFBProfile = [UIImage imageWithData: data];
                    hud.hidden = YES;
                    [userDefaults setObject: data forKey: @"facebook_logo_data"];
                    [userDefaults synchronize];
                    // loading Left Side Menu once again
                    [app addMFSideMenu];
                });
            });
            
        }
        
//        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
//         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//             
//             if (!error) {
//                 currentEmail = [[[FIRAuth auth] currentUser] email];
//                 NSLog(@"fetched user:%@  and Email : %@", result,result[@"email"]);
//                 NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal",result[@"id"]]];
//                 
//                 (result[@"email"] != nil) ? mUserEmail = result[@"email"] : @"";
//                 (result[@"id"]) ? mUserID = result[@"id"] : @"";
//                 (result[@"name"]) ? mUserName = result[@"name"] : @"";
//                 
//                 app.mUserName = mUserName;
//                 app.mUserEmail = currentEmail;
//                 app.mUserID = mUserID;
//                 
//                 [userName setText: [@"Name  : " stringByAppendingString: mUserName]];
//                 [userid setText: [  @"UserID: " stringByAppendingString: mUserID]];
//                 [userEmail setText: [@"Email : " stringByAppendingString: currentEmail]];
//                 
//                 
//                 dispatch_async(dispatch_get_global_queue(0,0), ^{
//                     NSData *data = [NSData dataWithContentsOfURL:url];
//                     if ( data == nil )
//                         return;
//                     dispatch_async(dispatch_get_main_queue(), ^{
//                         // WARNING: is the cell still using the same data by this point??
//                         app.mFBProfile = [UIImage imageWithData: data];
//                         hud.hidden = YES;
//                         [userDefaults setObject: data forKey: @"facebook_logo_data"];
//                         [userDefaults synchronize];
//                         // loading Left Side Menu once again
//                         [app addMFSideMenu];
//                     });
//                 });
//                 
//             } else
//                 [self showMessagePrompt: error.localizedDescription];
//         }];
        
    } else
    {
        
        app.mFBProfile = [UIImage imageWithData: mData];
//        [userName setText: [@"Name  : " stringByAppendingString: mUserName]];
//        [userid setText: [  @"UserID: " stringByAppendingString: mUserID]];
//        [userEmail setText: [@"Email : " stringByAppendingString: mUserEmail]];
    }
    
    
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView1{
    
    int fontSize = 100;
    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'", fontSize];
    [webView1 stringByEvaluatingJavaScriptFromString:jsString];
    
}

- (void) initProfilePage
{
    // show TransactionView if there are data in Transactions
    
    [table_view registerNib: [UINib nibWithNibName: @"CustomTableFinancialAccountsTableViewCell" bundle:nil] forCellReuseIdentifier: @"cell_financial"];
    shopperCategoriesAmounts = [[NSArray alloc] init];
    arrForLineGraphData = [[NSMutableArray alloc] init];
    arrForLineGraphDataLastMonth = [[NSMutableArray alloc] init];
    app.arrForLineGraphDataLastMonth = [[NSMutableArray alloc] init];
    app.arrForLineGraphDataCurrentMonth = [[NSMutableArray alloc] init];
    arrayItems = [[NSArray alloc] init];
    app.maxAmount = 0.0;
    app.isMaxInLast = false;
    
    // make veritcal label
    CGAffineTransform transA = CGAffineTransformMakeTranslation(0,mVerticalTextLabel.frame.size.height/2);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(-M_PI_2);
    CGAffineTransform transB = CGAffineTransformMakeTranslation(-mVerticalTextLabel.frame.size.width/2,-mVerticalTextLabel.frame.size.height/2);
    mVerticalTextLabel.transform = CGAffineTransformConcat(CGAffineTransformConcat(transA,rotation),transB);

//    mVerticalTextLabel.transform = CGAffineTransformMakeRotation((270*M_PI)/180);
    [self retrievTransactions];
    
}

- (void) retrievTransactions
{
    FIRDatabaseReference *dbRef;
    NSString *userID = [[[FIRAuth auth] currentUser] uid];
//    userID = @"EGSKXZWM3COl253jke9bi5eCzSI3";
    [self showProgressBar: @"Retrieving Transactions..."];
    dbRef = [[[[FIRDatabase database] reference] child: userID] child: @"financial_db"];
    if (dbRef != nil) {
        
        [dbRef observeSingleEventOfType:(FIRDataEventTypeValue) withBlock: ^(FIRDataSnapshot *_Nonnull snapshot) {
            hud.hidden = YES;
            if ([snapshot exists]) {
                NSMutableArray *arr_lastMonthTransactions = [[NSMutableArray alloc] init];
                NSMutableArray *arr_currentMonthTransactions = [[NSMutableArray alloc] init];
                for (snapshot in snapshot.children) { // loop in all institution id (bank accounts)
                    NSDictionary *dic = snapshot.value;
                    NSArray *lastTransactions = [dic objectForKey: @"last_month_transactions"];
                    NSArray *currentTransactions = [dic objectForKey: @"transactions"];
                    
                    for (int i=0; i<lastTransactions.count; i++) {
                        [arr_lastMonthTransactions addObject: [lastTransactions objectAtIndex: i]];
                    }
                    
                    for (int i=0; i<currentTransactions.count; i++) {
                        [arr_currentMonthTransactions addObject: [currentTransactions objectAtIndex: i]];
                    }
                    
                }
                
                [self getMaxAmount: arr_currentMonthTransactions lastMonthArray: arr_lastMonthTransactions];
                if (app.isMaxInLast) {
                    if (arr_lastMonthTransactions != nil) {
                        [self handleWithLastMonthTransactions: arr_lastMonthTransactions];
                        double delayInSeconds = 1.5;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            if (arr_currentMonthTransactions != nil) {
                                [self handleWithCurrentMonthTransactions: arr_currentMonthTransactions];
                            }
                        });
                    }
                } else
                {
                    if (arr_currentMonthTransactions != nil) {
                        [self handleWithCurrentMonthTransactions: arr_currentMonthTransactions];
                        double delayInSeconds = 1.5;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            if (arr_lastMonthTransactions != nil) {
                                [self handleWithLastMonthTransactions: arr_lastMonthTransactions];
                            }
                        });
                    }
                }
                
                // show transactionView
                transactionView.hidden = NO;
                bottomLabelView.hidden = YES;
                
                
            } else
            {
                // hide transactionView
                transactionView.hidden = YES;
                bottomLabelView.hidden = NO;
            }
        }];
        
    } else
    {
        // hide transactionView
        transactionView.hidden = YES;
        bottomLabelView.hidden = NO;
    }
}

- (void) getMaxAmount: (NSArray *) currentMonthTransactions lastMonthArray: (NSArray *) lastMonthTransactions
{
    CGFloat tempAmount = 0;
    CGFloat mMaxAmountInCurrentMonth=0, mMaxAmountInLastMonth=0;
    CGFloat amountOfSameTransactions[6] = {0,0,0,0,0,0};
    NSString *transactionName;
    CGFloat transactionAmount;
    NSDictionary *everyTransaction;
    
    if (currentMonthTransactions != nil) {
        
        
        for (int i=0; i<currentMonthTransactions.count; i++) {
            everyTransaction = [currentMonthTransactions objectAtIndex:i];
            
            NSArray *category = [everyTransaction objectForKey: @"category"];
            NSString *transactionName;
            if (category != nil) {
                transactionName = [category objectAtIndex: 0];
            } else
                transactionName = @"other";
            transactionAmount = [[everyTransaction objectForKey: @"amount"] floatValue];
            //                            NSString *transactionDate = [everyTransaction objectForKey: @"date"];
            if (transactionAmount <= 0) {
                continue;
            }
            if ([transactionName isEqualToString: @"Shops"]) {
                amountOfSameTransactions[0]+= transactionAmount;
            } else if ([transactionName isEqualToString: @"Food and Drink"]) {
                amountOfSameTransactions[1]+= transactionAmount;
            }else if ([transactionName isEqualToString: @"Travel"]) {
                amountOfSameTransactions[2]+= transactionAmount;
            }else if ([transactionName isEqualToString: @"Service"]) {
                amountOfSameTransactions[3]+= transactionAmount;
            } else
            {
                // other
                amountOfSameTransactions[4]+= transactionAmount;
            }
            
        }
        
        // qsort transaction amounts
        for (int i=0; i<4; i++) {
            for (int j=i; j<5; j++) {
                if (amountOfSameTransactions[j] < 0) {
                    amountOfSameTransactions[j] = 0 - amountOfSameTransactions[j];
                }
                if (amountOfSameTransactions[i] < amountOfSameTransactions[j]) {
                    tempAmount = amountOfSameTransactions[i];
                    amountOfSameTransactions[i] = amountOfSameTransactions[j];
                    amountOfSameTransactions[j] = tempAmount;
                }
                mMaxAmountInCurrentMonth = amountOfSameTransactions[0];
            }
        }
        
        for (int i=0; i<6; i++) {
            amountOfSameTransactions[i] = 0;
        }
    }
    
    // calculate in last month
    
    if (lastMonthTransactions != nil) {
        
        
        for (int i=0; i<lastMonthTransactions.count; i++) {
            everyTransaction = [lastMonthTransactions objectAtIndex:i];
            
            NSArray *category = [everyTransaction objectForKey: @"category"];
            NSString *transactionName;
            if (category != nil) {
                transactionName = [category objectAtIndex: 0];
            } else
                transactionName = @"other";
            transactionAmount = [[everyTransaction objectForKey: @"amount"] floatValue];
            //                            NSString *transactionDate = [everyTransaction objectForKey: @"date"];
            if (transactionAmount <= 0) {
                continue;
            }
            
            if ([transactionName isEqualToString: @"Shops"]) {
                amountOfSameTransactions[0]+= transactionAmount;
            } else if ([transactionName isEqualToString: @"Food and Drink"]) {
                amountOfSameTransactions[1]+= transactionAmount;
            }else if ([transactionName isEqualToString: @"Travel"]) {
                amountOfSameTransactions[2]+= transactionAmount;
            }else if ([transactionName isEqualToString: @"Service"]) {
                amountOfSameTransactions[3]+= transactionAmount;
            } else
            {
                // other
                amountOfSameTransactions[4]+= transactionAmount;
            }
            
        }
        
        // qsort transaction amounts
        for (int i=0; i<4; i++) {
            for (int j=i; j<5; j++) {
                if (amountOfSameTransactions[j] < 0) {
                    amountOfSameTransactions[j] = 0 - amountOfSameTransactions[j];
                }
                if (amountOfSameTransactions[i] < amountOfSameTransactions[j]) {
                    tempAmount = amountOfSameTransactions[i];
                    amountOfSameTransactions[i] = amountOfSameTransactions[j];
                    amountOfSameTransactions[j] = tempAmount;
                }
                mMaxAmountInLastMonth = amountOfSameTransactions[0];
            }
        }
    }
    if (mMaxAmountInCurrentMonth > mMaxAmountInLastMonth)
    {
        app.maxAmount = mMaxAmountInCurrentMonth;
        app.isMaxInLast = false;
    }
    else{
        app.maxAmount = mMaxAmountInLastMonth;
        app.isMaxInLast = true;
    }
//    app.maxAmount = 5009.25;
//    app.isMaxInLast = true;
    NSLog(@"Max Amount in Categories : %.1f", app.maxAmount);
}

- (void) handleWithCurrentMonthTransactions:(NSArray *) arr
{
    // handle with current month transactions
    
    int sizeOfSameTransactions[6] = {0,0,0,0,0,0};
    CGFloat amountOfSameTransactions[6] = {0,0,0,0,0,0};
    
    for (int i=0; i<arr.count; i++) {
        NSDictionary *everyTransaction = [arr objectAtIndex:i];
        
        NSArray *category = [everyTransaction objectForKey: @"category"];
        NSString *transactionName;
        if (category != nil) {
            transactionName = [category objectAtIndex: 0];
        } else
            transactionName = @"other";
        CGFloat transactionAmount = [[everyTransaction objectForKey: @"amount"] floatValue];
        //                            NSString *transactionDate = [everyTransaction objectForKey: @"date"];
        if (transactionAmount <= 0) {
            continue;
        }

        if ([transactionName isEqualToString: @"Shops"]) {
            sizeOfSameTransactions[0]++;
            amountOfSameTransactions[0]+= transactionAmount;
        } else if ([transactionName isEqualToString: @"Food and Drink"]) {
            sizeOfSameTransactions[1]++;
            amountOfSameTransactions[1]+= transactionAmount;
        }else if ([transactionName isEqualToString: @"Travel"]) {
            sizeOfSameTransactions[2]++;
            amountOfSameTransactions[2]+= transactionAmount;
        }else if ([transactionName isEqualToString: @"Service"]) {
            sizeOfSameTransactions[3]++;
            amountOfSameTransactions[3]+= transactionAmount;
        } else
        {
            // other
            sizeOfSameTransactions[4]++;
            amountOfSameTransactions[4]+= transactionAmount;
        }
        
    }
    
    
    // create array
    NSDictionary *dic_pharmacy, *dic_home, *dic_travel, *dic_entertainment, *dic_other;
    dic_pharmacy = dic_home = dic_travel = dic_entertainment = dic_other = nil;
    NSMutableArray *arr_temp = [[NSMutableArray alloc] init];
    NSString *tempAmount1, *tempAmount2, *tempAmount3, *tempAmount4, *tempAmount5,
    *amountForChart1, *amountForChart2, *amountForChart3, *amountForChart4, *amountForChart5;
    tempAmount1 = tempAmount2 = tempAmount3 = tempAmount4 = tempAmount5 =
    amountForChart1 = amountForChart2 = amountForChart3 = amountForChart4 = amountForChart5 = @"0";
    
    NSString *colorChart1, *colorChart2, *colorChart3, *colorChart4, *colorChart5;
    colorChart1 = colorChart2 = colorChart3 = colorChart4 = colorChart5 = @"000000";
    
//    sizeOfSameTransactions[0] = 2;
//    
//    amountOfSameTransactions[0] = -2500;
    if (amountOfSameTransactions[0] != 0) {
        if (amountOfSameTransactions[0] < 0) {
            amountOfSameTransactions[0] = 0 - amountOfSameTransactions[0];
            tempAmount1 = [NSString stringWithFormat: @"-%.1f", amountOfSameTransactions[0]];
            //                                colorChart1 = @"FF0000";
        } else
        {
            tempAmount1 = [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[0]];
        }
        amountForChart1 = [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[0]];
        dic_pharmacy = [NSDictionary dictionaryWithObjectsAndKeys: @"shops_icon", @"icon",
                        @"Shops", @"category",
                        [NSString stringWithFormat: @"%d Transactions", sizeOfSameTransactions[0]], @"counts",
                        tempAmount1, @"amount", nil];
        [arr_temp addObject: dic_pharmacy];
        [arrForLineGraphData addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"Shops", @"category", [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[0]], @"amount", nil]];
    } else
    {
        [arrForLineGraphData addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"Shops", @"category", @"0", @"amount", nil]];
    }
    
    if (amountOfSameTransactions[1] != 0) {
        if (amountOfSameTransactions[1] < 0) {
            amountOfSameTransactions[1] = 0 - amountOfSameTransactions[1];
            tempAmount2 = [NSString stringWithFormat: @"-%.1f", amountOfSameTransactions[1]];
            //                                colorChart2 = @"FF0000";
        } else
        {
            tempAmount2 = [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[1]];
        }
        amountForChart2 = [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[1]];
        dic_home = [NSDictionary dictionaryWithObjectsAndKeys: @"food_and_drinks_icon", @"icon",
                    @"Food and Drink", @"category",
                    [NSString stringWithFormat: @"%d Transactions", sizeOfSameTransactions[1]], @"counts",
                    tempAmount2, @"amount", nil];
        [arr_temp addObject: dic_home];
        [arrForLineGraphData addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"FoodAndDrink", @"category", [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[1]], @"amount", nil]];
    } else
    {
        [arrForLineGraphData addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"FoodAndDrinks", @"category", @"0", @"amount", nil]];
    }
    
    if (amountOfSameTransactions[2] != 0) {
        if (amountOfSameTransactions[2] < 0) {
            amountOfSameTransactions[2] = 0 - amountOfSameTransactions[2];
            tempAmount3 = [NSString stringWithFormat: @"-%.1f", amountOfSameTransactions[2]];
            //                                colorChart3 = @"FF0000";
        } else
        {
            tempAmount3 = [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[2]];
        }
        amountForChart3 = [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[2]];
        dic_travel = [NSDictionary dictionaryWithObjectsAndKeys: @"travel_icon", @"icon",
                      @"Travel", @"category",
                      [NSString stringWithFormat: @"%d Transactions", sizeOfSameTransactions[2]], @"counts",
                      tempAmount3, @"amount", nil];
        [arr_temp addObject: dic_travel];
        [arrForLineGraphData addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"Travel", @"category", [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[2]], @"amount", nil]];
    } else
    {
        [arrForLineGraphData addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"Travel", @"category", @"0", @"amount", nil]];
    }
    
    if (amountOfSameTransactions[3] != 0) {
        if (amountOfSameTransactions[3] < 0) {
            amountOfSameTransactions[3] = 0 - amountOfSameTransactions[3];
            tempAmount4 = [NSString stringWithFormat: @"-%.1f", amountOfSameTransactions[3]];
            //                                colorChart4 = @"FF0000";
        } else
        {
            tempAmount4 = [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[3]];
        }
        amountForChart4 = [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[3]];
        dic_entertainment = [NSDictionary dictionaryWithObjectsAndKeys: @"services_icon", @"icon",
                             @"Service", @"category",
                             [NSString stringWithFormat: @"%d Transactions", sizeOfSameTransactions[3]], @"counts",
                             tempAmount4, @"amount", nil];
        [arr_temp addObject: dic_entertainment];
        [arrForLineGraphData addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"Service", @"category", [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[3]], @"amount", nil]];
    } else
    {
        [arrForLineGraphData addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"Service", @"category", @"0", @"amount", nil]];
    }
    
    if (amountOfSameTransactions[4] != 0) {
        if (amountOfSameTransactions[4] < 0) {
            amountOfSameTransactions[4] = 0 - amountOfSameTransactions[4];
            tempAmount5 = [NSString stringWithFormat: @"-%.1f", amountOfSameTransactions[4]];
            //                                colorChart5 = @"FF0000";
        } else
        {
            tempAmount5 = [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[4]];
        }
        amountForChart5 = [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[4]];
        dic_other = [NSDictionary dictionaryWithObjectsAndKeys: @"other_icon", @"icon",
                     @"Other", @"category",
                     [NSString stringWithFormat: @"%d Transactions", sizeOfSameTransactions[4]], @"counts",
                     tempAmount5, @"amount", nil];
        [arr_temp addObject: dic_other];
        [arrForLineGraphData addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"Other", @"category", [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[4]], @"amount", nil]];
    } else
    {
        [arrForLineGraphData addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"Other", @"category", @"0", @"amount", nil]];
    }
    
    shopperCategoriesAmounts = [[NSArray alloc] initWithArray: arr_temp];
    
    if (app.isMaxInLast) {
        // reset array
        if (!app.arrForLineGraphDataCurrentMonth) app.arrForLineGraphDataCurrentMonth = [[NSMutableArray alloc] init];
        [app.arrForLineGraphDataCurrentMonth removeAllObjects];
        
        for (int i=0; i<arrForLineGraphData.count; i++) {
            NSDictionary *dic = [arrForLineGraphData objectAtIndex: i];
            NSString *mCategory = [dic objectForKey: @"category"];
            NSString *mAmount = [dic objectForKey: @"amount"];
            
            [self.arrayOfDates addObject: mCategory];
            [app.arrForLineGraphDataCurrentMonth addObject: mAmount];
        }
        
        [app.arrForLineGraphDataCurrentMonth addObject: @"0"];
    } else
    {
        
        
        // draw line graph
        self.myGraph.delegate = self;
        self.myGraph.dataSource = self;
        [self hydrateDatasets];
        
    }
    
    [self initLineGraph];
    [table_view reloadData];
    // draw bar chart
    /*
     arrayItems = [barChartView createChartDataWithTitles:[NSArray arrayWithObjects:@"Pharmacy", @"Home", @"Travel", @"Entertainment", @"Other", nil]
     values:[NSArray arrayWithObjects:
     amountForChart1,
     amountForChart2,
     amountForChart3,
     amountForChart4,
     amountForChart5, nil]
     colors:[NSArray arrayWithObjects:colorChart1, colorChart2, colorChart3, colorChart4, colorChart5, nil]
     labelColors:[NSArray arrayWithObjects:@"000000", @"000000", @"000000", @"000000", @"000000", nil]];
     
     // qsort amounts
     long maxAmount = 0;
     for (int i=0; i<4; i++) {
     for (int j=i; j<5; j++) {
     if (amountOfSameTransactions[i] < amountOfSameTransactions[j]) {
     maxAmount = amountOfSameTransactions[i];
     amountOfSameTransactions[i] = amountOfSameTransactions[j];
     amountOfSameTransactions[j] = maxAmount;
     }
     }
     }
     app.maxAmount = amountOfSameTransactions[0];
     // draw chat
     //Set the Shape of the Bars (Rounded or Squared) - Rounded is default
     [barChartView setupBarViewShape:BarShapeSquared];
     
     //Set the Style of the Bars (Glossy, Matte, or Flat) - Glossy is default
     [barChartView setupBarViewStyle:BarStyleGlossy];
     
     //Set the Drop Shadow of the Bars (Light, Heavy, or None) - Light is default
     [barChartView setupBarViewShadow:BarShadowLight];
     
     //Generate the bar chart using the formatted data
     [barChartView setDataWithArray:arrayItems
     showAxis:DisplayBothAxes
     withColor:[UIColor whiteColor]
     shouldPlotVerticalLines:YES];*/
    
}

- (void) handleWithLastMonthTransactions:(NSArray *) arr
{
    // handle with last month transactions
    
    int sizeOfSameTransactions[6] = {0,0,0,0,0,0};
    CGFloat amountOfSameTransactions[6] = {0,0,0,0,0,0};
    
    for (int i=0; i<arr.count; i++) {
        NSDictionary *everyTransaction = [arr objectAtIndex:i];
        
        NSArray *category = [everyTransaction objectForKey: @"category"];
        NSString *transactionName;
        if (category != nil) {
            transactionName = [category objectAtIndex: 0];
        } else
            transactionName = @"other";
        
        CGFloat transactionAmount = [[everyTransaction objectForKey: @"amount"] longValue];
        //                            NSString *transactionDate = [everyTransaction objectForKey: @"date"];
        if (transactionAmount <= 0) {
            continue;
        }

        if ([transactionName isEqualToString: @"Shops"]) {
            sizeOfSameTransactions[0]++;
            amountOfSameTransactions[0]+= transactionAmount;
        } else if ([transactionName isEqualToString: @"Food and Drink"]) {
            sizeOfSameTransactions[1]++;
            amountOfSameTransactions[1]+= transactionAmount;
        }else if ([transactionName isEqualToString: @"Travel"]) {
            sizeOfSameTransactions[2]++;
            amountOfSameTransactions[2]+= transactionAmount;
        }else if ([transactionName isEqualToString: @"Service"]) {
            sizeOfSameTransactions[3]++;
            amountOfSameTransactions[3]+= transactionAmount;
        } else
        {
            // other
            sizeOfSameTransactions[4]++;
            amountOfSameTransactions[4]+= transactionAmount;
        }
        
    }
    
    // create array
    NSMutableArray *arr_temp = [[NSMutableArray alloc] init];
    NSDictionary *dic_pharmacy, *dic_home, *dic_travel, *dic_entertainment, *dic_other;
    dic_pharmacy = dic_home = dic_travel = dic_entertainment = dic_other = nil;
    NSString *tempAmount1, *tempAmount2, *tempAmount3, *tempAmount4, *tempAmount5,
    *amountForChart1, *amountForChart2, *amountForChart3, *amountForChart4, *amountForChart5;
    tempAmount1 = tempAmount2 = tempAmount3 = tempAmount4 = tempAmount5 =
    amountForChart1 = amountForChart2 = amountForChart3 = amountForChart4 = amountForChart5 = @"0";
    
    NSString *colorChart1, *colorChart2, *colorChart3, *colorChart4, *colorChart5;
    colorChart1 = colorChart2 = colorChart3 = colorChart4 = colorChart5 = @"000000";
    
    
//    amountOfSameTransactions[0] = 5009.25;
    if (amountOfSameTransactions[0] != 0) {
        if (amountOfSameTransactions[0] < 0) {
            amountOfSameTransactions[0] = 0 - amountOfSameTransactions[0];
            tempAmount1 = [NSString stringWithFormat: @"-%.1f", amountOfSameTransactions[0]];
            //                                colorChart1 = @"FF0000";
        } else
        {
            tempAmount1 = [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[0]];
        }
        dic_pharmacy = [NSDictionary dictionaryWithObjectsAndKeys: @"shops_icon", @"icon",
                        @"Shops", @"category",
                        [NSString stringWithFormat: @"%d Transactions", sizeOfSameTransactions[0]], @"counts",
                        tempAmount1, @"amount", nil];
        [arr_temp addObject: dic_pharmacy];
        [arrForLineGraphDataLastMonth addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"Shops", @"category", [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[0]], @"amount", nil]];
    } else
    {
        [arrForLineGraphDataLastMonth addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"Shops", @"category", @"0", @"amount", nil]];
    }
    
    if (amountOfSameTransactions[1] != 0) {
        if (amountOfSameTransactions[1] < 0) {
            amountOfSameTransactions[1] = 0 - amountOfSameTransactions[1];
            tempAmount2 = [NSString stringWithFormat: @"-%.1f", amountOfSameTransactions[1]];
            //                                colorChart2 = @"FF0000";
        } else
        {
            tempAmount2 = [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[1]];
        }
        dic_home = [NSDictionary dictionaryWithObjectsAndKeys: @"food_and_drinks_icon", @"icon",
                    @"Food and Drink", @"category",
                    [NSString stringWithFormat: @"%d Transactions", sizeOfSameTransactions[1]], @"counts",
                    tempAmount2, @"amount", nil];
        [arr_temp addObject: dic_home];
        [arrForLineGraphDataLastMonth addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"FoodAndDrink", @"category", [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[1]], @"amount", nil]];
    } else
    {
        [arrForLineGraphDataLastMonth addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"FoodAndDrinks", @"category", @"0", @"amount", nil]];
    }
    
    if (amountOfSameTransactions[2] != 0) {
        if (amountOfSameTransactions[2] < 0) {
            amountOfSameTransactions[2] = 0 - amountOfSameTransactions[2];
            tempAmount3 = [NSString stringWithFormat: @"-%.1f", amountOfSameTransactions[2]];
            //                                colorChart3 = @"FF0000";
        } else
        {
            tempAmount3 = [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[2]];
        }
        dic_travel = [NSDictionary dictionaryWithObjectsAndKeys: @"travel_icon", @"icon",
                      @"Travel", @"category",
                      [NSString stringWithFormat: @"%d Transactions", sizeOfSameTransactions[2]], @"counts",
                      tempAmount3, @"amount", nil];
        [arr_temp addObject: dic_travel];
        [arrForLineGraphDataLastMonth addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"Travel", @"category", [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[2]], @"amount", nil]];
    } else
    {
        [arrForLineGraphDataLastMonth addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"Travel", @"category", @"0", @"amount", nil]];
    }
    
    if (amountOfSameTransactions[3] != 0) {
        if (amountOfSameTransactions[3] < 0) {
            amountOfSameTransactions[3] = 0 - amountOfSameTransactions[3];
            tempAmount4 = [NSString stringWithFormat: @"-%.1f", amountOfSameTransactions[3]];
            //                                colorChart4 = @"FF0000";
        } else
        {
            tempAmount4 = [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[3]];
        }
        dic_entertainment = [NSDictionary dictionaryWithObjectsAndKeys: @"services_icon", @"icon",
                             @"Service", @"category",
                             [NSString stringWithFormat: @"%d Transactions", sizeOfSameTransactions[3]], @"counts",
                             tempAmount4, @"amount", nil];
        [arr_temp addObject: dic_entertainment];
        [arrForLineGraphDataLastMonth addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"Service", @"category", [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[3]], @"amount", nil]];
    } else
    {
        [arrForLineGraphDataLastMonth addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"Service", @"category", @"0", @"amount", nil]];
    }
    
    if (amountOfSameTransactions[4] != 0) {
        if (amountOfSameTransactions[4] < 0) {
            amountOfSameTransactions[4] = 0 - amountOfSameTransactions[4];
            tempAmount5 = [NSString stringWithFormat: @"-%.1f", amountOfSameTransactions[4]];
            //                                colorChart5 = @"FF0000";
        } else
        {
            tempAmount5 = [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[4]];
        }
        dic_other = [NSDictionary dictionaryWithObjectsAndKeys: @"other_icon", @"icon",
                     @"Other", @"category",
                     [NSString stringWithFormat: @"%d Transactions", sizeOfSameTransactions[4]], @"counts",
                     tempAmount5, @"amount", nil];
        [arr_temp addObject: dic_other];
        [arrForLineGraphDataLastMonth addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"Other", @"category", [NSString stringWithFormat: @"%.1f", amountOfSameTransactions[4]], @"amount", nil]];
    } else
    {
        [arrForLineGraphDataLastMonth addObject: [NSDictionary dictionaryWithObjectsAndKeys: @"Other", @"category", @"0", @"amount", nil]];
    }
    
    
    if (!app.isMaxInLast) {
        // reset array
        if (!app.arrForLineGraphDataLastMonth) app.arrForLineGraphDataLastMonth = [[NSMutableArray alloc] init];
        [app.arrForLineGraphDataLastMonth removeAllObjects];
        
        for (int i=0; i<arrForLineGraphDataLastMonth.count; i++) {
            NSDictionary *dic = [arrForLineGraphDataLastMonth objectAtIndex: i];
            NSString *mCategory = [dic objectForKey: @"category"];
            NSString *mAmount = [dic objectForKey: @"amount"];
            
            [self.arrayOfDates addObject: mCategory];
            [app.arrForLineGraphDataLastMonth addObject: mAmount];
        }
        
        [app.arrForLineGraphDataLastMonth addObject: @"0"];
    } else
    {
//        shopperCategoriesAmounts = [[NSArray alloc] initWithArray: arr_temp];
        // draw line graph
        self.myGraph.delegate = self;
        self.myGraph.dataSource = self;
        [self hydrateDatasets];
    }
    
    [self initLineGraph];
}

- (void) initLineGraph
{
    // Create a gradient to apply to the bottom portion of the graph
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 0.0
    };
    
    // Apply the gradient to the bottom portion of the graph
    self.myGraph.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    
    // Enable and disable various graph properties and axis displays
    self.myGraph.enableTouchReport = NO;
    self.myGraph.enablePopUpReport = NO;
    self.myGraph.enableYAxisLabel = YES;
    self.myGraph.autoScaleYAxis = YES;
    self.myGraph.alwaysDisplayDots = NO;
    self.myGraph.enableReferenceXAxisLines = YES;
    self.myGraph.enableReferenceYAxisLines = YES;
    self.myGraph.enableReferenceAxisFrame = YES;
    
    // Draw an average line
    self.myGraph.averageLine.enableAverageLine = YES;
    self.myGraph.averageLine.alpha = 0.6;
    self.myGraph.averageLine.color = [UIColor darkGrayColor];
    self.myGraph.averageLine.width = 2.5;
    self.myGraph.averageLine.dashPattern = @[@(2),@(2)];
    
    // Set the graph's animation style to draw, fade, or none
    self.myGraph.animationGraphStyle = BEMLineAnimationDraw;
    
    // Dash the y reference lines
    self.myGraph.lineDashPatternForReferenceYAxisLines = @[@(2),@(2)];
    
    // Show the y axis values with this format string
    self.myGraph.formatStringForValues = @"%.1f";
    
    
    // The labels to report the values of the graph when the user touches it
    //    self.labelValues.text = [NSString stringWithFormat:@"%i", [[self.myGraph calculatePointValueSum] intValue]];
    self.labelValues.text = @"";
    self.labelDates.text = @"";
    
    [self.myGraph reloadGraph];
}

- (void)hydrateDatasets {
    // Reset the arrays of values (Y-Axis points) and dates (X-Axis points / labels)
    if (!self.arrayOfValues) self.arrayOfValues = [[NSMutableArray alloc] init];
    if (!self.arrayOfDates) self.arrayOfDates = [[NSMutableArray alloc] init];
    [self.arrayOfValues removeAllObjects];
    [self.arrayOfDates removeAllObjects];
    if (app.isMaxInLast) {
        for (int i=0; i<arrForLineGraphDataLastMonth.count; i++) {
            NSDictionary *dic = [arrForLineGraphDataLastMonth objectAtIndex: i];
            NSString *mCategory = [dic objectForKey: @"category"];
            NSString *mAmount = [dic objectForKey: @"amount"];
            
            [self.arrayOfDates addObject: mCategory];
            [self.arrayOfValues addObject: mAmount];
        }
    } else
    {
        for (int i=0; i<arrForLineGraphData.count; i++) {
            NSDictionary *dic = [arrForLineGraphData objectAtIndex: i];
            NSString *mCategory = [dic objectForKey: @"category"];
            NSString *mAmount = [dic objectForKey: @"amount"];
            
            [self.arrayOfDates addObject: mCategory];
            [self.arrayOfValues addObject: mAmount];
        }
    }
    
    
    [self.arrayOfDates addObject: @" "];
    [self.arrayOfValues addObject: @"0"];
//
//    self.arrayOfDates = [NSMutableArray arrayWithObjects:
//                         @"Pharmacy",
//                         @"Home",
//                         @"Travel",
//                         @"Entertainment",
//                         @"Other",
//                         @" ", nil];
//    self.arrayOfValues = [NSMutableArray arrayWithObjects:
//                          @"0",
//                          @"0",
//                          @"0",
//                          @"-2500",
//                          @"0",
//                          @"0", nil];
//
    NSLog( @"%@", self.arrayOfValues);
    NSLog( @"%@", self.arrayOfDates);
    
}


#pragma mark - SimpleLineGraph Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    NSLog(@"-----%d", (int)[self.arrayOfValues count]);
    return (int)[self.arrayOfValues count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [[self.arrayOfValues objectAtIndex:index] doubleValue];
}

#pragma mark - SimpleLineGraph Delegate

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 80;
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    
    NSString *label = [self.arrayOfDates objectAtIndex: index];
    return [label stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
    self.labelValues.text = [NSString stringWithFormat:@"$ %@", [self.arrayOfValues objectAtIndex:index]];
    self.labelDates.text = [self.arrayOfDates objectAtIndex: index];
    
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.labelValues.alpha = 0.0;
        self.labelDates.alpha = 0.0;
    } completion:^(BOOL finished) {
        if ([self.labelValues.text length] != 0) {
            self.labelValues.text = [NSString stringWithFormat:@"$ %@", [self.arrayOfValues objectAtIndex:index]];
            self.labelDates.text = [self.arrayOfDates objectAtIndex: index];
        }
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.labelValues.alpha = 1.0;
            self.labelDates.alpha = 1.0;
        } completion:nil];
    }];
}

- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph {
    //    self.labelValues.text = [NSString stringWithFormat:@"%i", [[self.myGraph calculatePointValueSum] intValue]];
    //    self.labelDates.text = [self labelForDateAtIndex:self.arrayOfDates.count - 1];
}

/* - (void)lineGraphDidFinishDrawing:(BEMSimpleLineGraphView *)graph {
 // Use this method for tasks after the graph has finished drawing
 } */

//- (NSString *)popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph {
//    return @" people";
//}

- (NSString *)popUpPrefixForlineGraph:(BEMSimpleLineGraphView *)graph {
    return @"$ ";
}



- (void) showProgressBar: (NSString *) message
{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = message;
}

#pragma mark UITableViewDelegate & DataSource for ChartView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    tableView.allowsSelection = NO;
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return shopperCategoriesAmounts.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableFinancialAccountsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell_financial" forIndexPath:indexPath];
    NSDictionary *dic = [shopperCategoriesAmounts objectAtIndex: indexPath.row];
    
    cell.logo_img.hidden = YES;
    cell.logo_img_ChartView.image = [UIImage imageNamed: [dic objectForKey: @"icon"]];
    cell.mLabelAccountName.text = [dic objectForKey: @"category"];
    cell.minstitutionName.text = [dic objectForKey: @"counts"];
    
    char negativeS = [[dic objectForKey: @"amount"] characterAtIndex:0];
//    if (negativeS == '-') {
////        cell.mAmounts.textColor = [UIColor redColor];
//    } else
////        cell.mAmounts.textColor = [UIColor blackColor];
    NSString *amountString = [dic objectForKey: @"amount"];
    float mFloatValue;
    if ([amountString hasPrefix: @"-"]) {
        amountString = [amountString substringWithRange: NSMakeRange(1, [amountString length] - 1)];
        mFloatValue = 0 - [amountString floatValue];
    } else
        mFloatValue = [amountString floatValue];
    cell.btn_add.hidden = NO;
    NSLog(@"%d -- tableviewCounts", shopperCategoriesAmounts.count);
    NSLog(@"table %d : ok ok ok", indexPath.row);
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    NSString *formatted = [formatter stringFromNumber: [NSNumber numberWithFloat: mFloatValue]];
    cell.mAmounts.text =[@"$ " stringByAppendingString: formatted];
//    if (indexPath.row == 0) {
//        cell.mAmounts.text =[@"$ " stringByAppendingString: formatted];
//    } else
//        cell.mAmounts.text = [@"$ " stringByAppendingString: [dic objectForKey: @"amount"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog( @"%d --- '%d'", (int)indexPath.row, (int)tableView.tag);
    [tableView deselectRowAtIndexPath: indexPath animated:YES];
    
}

- (void) labelBaseLineCreate
{
    // --------- Profile page
    
    CALayer *border1 = [CALayer layer];
    CGFloat borderWidth = 1;
    border1.borderColor = [UIColor blackColor].CGColor;
    border1.frame = CGRectMake(0, privacyPolicyLabel.frame.size.height - borderWidth, privacyPolicyLabel.frame.size.width, privacyPolicyLabel.frame.size.height);
    border1.borderWidth = borderWidth;
    [privacyPolicyLabel.layer addSublayer: border1];
    privacyPolicyLabel.layer.masksToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(gotoPrivacyPolicy)];
    [privacyPolicyLabel addGestureRecognizer:tap];
    
    
    CALayer *border2 = [CALayer layer];
    border2.frame = CGRectMake(0, feedbackLabel.frame.size.height - borderWidth, feedbackLabel.frame.size.width, feedbackLabel.frame.size.height);
    border2.borderWidth = borderWidth;
    [feedbackLabel.layer addSublayer: border2];
    feedbackLabel.layer.masksToBounds = YES;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(gotoFeedback)];
    [feedbackLabel addGestureRecognizer:tap1];
 
}

- (void) openFeedbackView:(id)sender
{
    
    if (app.feedbackAddButtonAndBackButtonFlag) {
        // close FeedbackView        
        bottomLabelView.hidden = NO;
        mScrollViewMerchantAccounts.hidden = NO;
        oldScrollviewFrame = mScrollViewMerchantAccounts.frame;
        if (app.isSelectedPlusButtonForHome == 0) {
            [mMerchantEating.view removeFromSuperview];
            mMerchantEating = [[MerchantEating alloc] initWithNibName: @"MerchantEating" bundle: nil];
            mMerchantEating.view.frame = CGRectMake(self.view.frame.size.width, 0, oldScrollviewFrame.size.width, oldScrollviewFrame.size.height);
            [mScrollViewMerchantAccounts addSubview: mMerchantEating.view];
        } else if (app.isSelectedPlusButtonForHome == 1)
        {
            // return to Pharmacy
            [mMerchantShops.view removeFromSuperview];
            
            mMerchantShops = [[MerchantShops alloc] initWithNibName: @"MerchantShops" bundle: nil];
            mMerchantShops.view.frame = CGRectMake(2*self.view.frame.size.width, 0, oldScrollviewFrame.size.width, oldScrollviewFrame.size.height);
            [mScrollViewMerchantAccounts addSubview:mMerchantShops.view];
        } else
        {
            
            // return to Coffee
            [mMerchantCoffee.view removeFromSuperview];
            
            mMerchantCoffee = [[MerchantAccountCoffee alloc] initWithNibName: @"MerchantAccountCoffee" bundle: nil];
            mMerchantCoffee.view.frame = CGRectMake(oldScrollviewFrame.origin.x, 0, oldScrollviewFrame.size.width, oldScrollviewFrame.size.height);
            [mScrollViewMerchantAccounts addSubview:mMerchantCoffee.view];
            
        }
        
        mScrollViewMerchantAccounts.contentMode = UIViewContentModeScaleToFill;
        
    } else
    {
        // hide social and label (privacy and feedback label)
        bottomLabelView.hidden = YES;
        
        // open FeedbackView
        // add FeedbackView
//        [mFeedbackView.view removeFromSuperview];
//        mFeedbackView = [self.storyboard instantiateViewControllerWithIdentifier:@"feedbackView"];
        
//        [self addChildViewController: mFeedbackView];
//        mFeedbackView.view.frame = merchantAccountFeedbackView.frame;
//        [merchantAccountFeedbackView addSubview: mFeedbackView.view];
//        [mFeedbackView didMoveToParentViewController: self];
        
//        merchantAccountFeedbackView.hidden = NO;
        mScrollViewMerchantAccounts.hidden = YES;
    }
    
}

- (void) initMerchantAccountsScrollView
{
//    mFeedbackView = [self.storyboard instantiateViewControllerWithIdentifier:@"feedbackView"];
//
//    [self addChildViewController: mFeedbackView];
//    mFeedbackView.view.frame = merchantAccountFeedbackView.frame;
//    [merchantAccountFeedbackView addSubview: mFeedbackView.view];
//    [mFeedbackView didMoveToParentViewController: self];
//
//    testButtonFlag = false;
//    merchantAccountFeedbackView.hidden = YES;
    
    mScrollViewMerchantAccounts.hidden = NO;
    
    // add notification target for add_button in TableView
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(openFeedbackView:)
//                                                 name:@"AddButtonPressed"
//                                               object:nil];
    
    currentX = 0.0f;
    oldScrollviewFrame = mScrollViewMerchantAccounts.frame;
    // add View to ScrollView
//    CGFloat widthOfScrollView = mScrollViewMerchantAccounts.frame.size.width;
//    CGFloat heightOfScrollView = mScrollViewMerchantAccounts.frame.size.height;
    
    mMerchantCoffee = [[MerchantAccountCoffee alloc] initWithNibName: @"MerchantAccountCoffee" bundle: nil];
    mMerchantCoffee.view.frame = CGRectMake(oldScrollviewFrame.origin.x, 0, oldScrollviewFrame.size.width, oldScrollviewFrame.size.height);
    [self addChildViewController: mMerchantCoffee];
    [mScrollViewMerchantAccounts addSubview: mMerchantCoffee.view];
    [mMerchantCoffee didMoveToParentViewController: self];
    
    mMerchantShops = [[MerchantShops alloc] initWithNibName: @"MerchantShops" bundle: nil];
    
    mMerchantShops.view.frame = CGRectMake(self.view.frame.size.width, 0, oldScrollviewFrame.size.width, oldScrollviewFrame.size.height);
    [self addChildViewController:mMerchantShops];
    [mScrollViewMerchantAccounts addSubview:mMerchantShops.view];
    [mMerchantShops didMoveToParentViewController: self];
    
    mMerchantEating = [[MerchantEating alloc] initWithNibName: @"MerchantEating" bundle:nil];
    [self addChildViewController:mMerchantEating];

    mMerchantEating.view.frame = CGRectMake(2*self.view.frame.size.width, 0, oldScrollviewFrame.size.width, oldScrollviewFrame.size.height);
    [mScrollViewMerchantAccounts addSubview: mMerchantEating.view];
    [mMerchantEating didMoveToParentViewController:self];
    
    mMerchantTravel = [[MerchantTravelViewController alloc] initWithNibName: @"MerchantTravelViewController" bundle: nil];
    
//    mMerchantTravel.view.frame = CGRectMake(3*self.view.frame.size.width, 0, oldScrollviewFrame.size.width, oldScrollviewFrame.size.height);
//    [self addChildViewController:mMerchantShops];
//    [mScrollViewMerchantAccounts addSubview:mMerchantTravel.view];
//    [mMerchantTravel didMoveToParentViewController: self];
    
    
    offSetX = self.view.frame.size.width-2;
    mScrollViewMerchantAccounts.contentSize = CGSizeMake(self.view.frame.size.width * 3,  100);
    mScrollViewMerchantAccounts.pagingEnabled = YES;
//    mScrollViewMerchantAccounts.autoresizesSubviews = YES;
    mScrollViewMerchantAccounts.contentMode = UIViewContentModeScaleToFill;
    
    [mEatingButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
    [mShopsButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
    [mCoffeeButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
//    [mTravelButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
}

- (IBAction)didSelectPhamacy:(id)sender {
    UIButton *selectedButton = (UIButton *) sender;
    if (selectedButton.tag == 10) { // tapped Coffee
        
        if (currentX == offSetX || currentX == 2*offSetX) {
            [mScrollViewMerchantAccounts setContentOffset:CGPointMake(0, 0) animated:YES];
            currentX = 0;
        }
        
        [mEatingButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
        [mShopsButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
        [mCoffeeButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
//        [mTravelButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
    } else if (selectedButton.tag == 20) // tapped Shops
    {
        
        if (currentX == 0 || currentX == 2*offSetX) {
            [mScrollViewMerchantAccounts setContentOffset:CGPointMake(offSetX, 0) animated:YES];
            currentX = offSetX;
        }
        
        
        
        [mEatingButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
        [mShopsButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [mCoffeeButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
//        [mTravelButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
    } else if (selectedButton.tag == 30) // Eating
    {
        // tapped Eating
        if (currentX == 0 || currentX == offSetX) {
            [mScrollViewMerchantAccounts setContentOffset:CGPointMake(2*offSetX, 0) animated:YES];
            currentX = 2*offSetX;
        }
        
        [mEatingButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [mShopsButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
        [mCoffeeButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
//        [mTravelButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
    }
//    else { // Travel
//        // tapped Travel
//        if (currentX == 0 || currentX == offSetX || currentX == 2*offSetX) {
//            [mScrollViewMerchantAccounts setContentOffset:CGPointMake(3*offSetX, 0) animated:YES];
//            currentX = 3*offSetX;
//        }
//
//        [mEatingButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
//        [mShopsButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
//        [mCoffeeButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
//        [mTravelButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
//    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    currentX = mScrollViewMerchantAccounts.contentOffset.x;
    NSLog( @"OFFSETX----- %f", offSetX);
    if (currentX == 0) {
        [mEatingButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
        [mShopsButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
        [mCoffeeButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
//        [mTravelButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
        
    } else if (currentX == offSetX)
    {
        [mEatingButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
        [mShopsButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [mCoffeeButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
//        [mTravelButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
//        offSetX = currentX;
        
    } else if (currentX == 2*offSetX)
    {
        [mEatingButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [mShopsButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
        [mCoffeeButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
//        [mTravelButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
//        offSetX = currentX;
    }
//    } else if (currentX == 3*offSetX)
//    {
//        [mEatingButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
//        [mShopsButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
//        [mCoffeeButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
//        [mTravelButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
//        //        offSetX = currentX;
//    }
    
    NSLog( @"CURRENTX----- %f", currentX);
    NSLog( @"LastOffSetX----- %f", offSetX);

}

- (void) addPlaidAPIViewController
{
    PlaidAPIViewController *mPlaidApiViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"plaidApiViewController"];
    
    [self addChildViewController: mPlaidApiViewController];
    mPlaidApiViewController.view.frame = CGRectMake(0, 0, _financialAccountsView.frame.size.width, _financialAccountsView.frame.size.height);
    [_financialAccountsView addSubview: mPlaidApiViewController.view];
    [mPlaidApiViewController didMoveToParentViewController: self];
}

- (void) gotoPrivacyPolicy
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.zealplatform.com/privacy"]];
}

- (void) gotoFeedback
{
    NSLog(@"pressed");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didSelectMenu:(id)sender {
    
     [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
    
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}
@end
