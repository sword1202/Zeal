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
//#import <LinkKit/LinkKit.h>
#import "PlaidAPIViewController.h"
#import "MerchantPharmacy.h"
#import "MerchantHome.h"
#import "MerchantAccountRateReviewsViewController.h"
#import "MFSideMenu.h"
#import "CustomTableFinancialAccountsTableViewCell.h"
@import FBSDKCoreKit;
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
    __weak IBOutlet UIImageView *imv_instagram;
    __weak IBOutlet UIImageView *imv_twitter;
    __weak IBOutlet UIImageView *imv_facebook;
    
    __weak IBOutlet UIView *bottomLabelView;
    __weak IBOutlet UIView *socialView;
    
    NSArray *shopperCategoriesAmounts;
    NSArray *arrayItems;
    __weak IBOutlet UIView *transactionView;
    
    // Merchant Accounts View
    
    __weak IBOutlet UIButton *mPhamacyButton;
    __weak IBOutlet UIButton *mHomeButton;
    CGFloat currentX, offSetX;
    
    // Financial Accounts View
    
    
    MBProgressHUD *hud;
    NSString *mUserName, *mUserEmail, *mUserID, *currentEmail;
    AppDelegate *app;
    MerchantPharmacy *mMerchantPharmacy;
    MerchantHome *mMerchantHome;
    CGRect oldScrollviewFrame;
    
    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *savedToken = [userDefaults objectForKey: @"access_token"];
    if (savedToken == nil) {
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
    [self imageViewGesture];
    
    // initialize webview for about page
    
    NSString *path = [[NSBundle mainBundle] pathForResource: @"about_text" ofType: @"html"];
    
    [webViewAbout loadRequest: [NSURLRequest requestWithURL: [NSURL fileURLWithPath: path isDirectory: NO]]];
    
    [self getFacebookProfile];
    
    
    
    
    self.profileView.hidden = YES;
    self.financialAccountsView.hidden = YES;
    self.merchantAccountsView.hidden = YES;
    self.aboutView.hidden = YES;
    
    switch (app.indexOfSelectedMenu) {
        case 1:
            // goto PROFILE VIEW
            [self initProfilePage];
           self.title = [[app.menuItems objectAtIndex: 1] objectForKey: @"name"];
            self.profileView.hidden = NO;
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

- (void) getFacebookProfile
{
    mUserID = app.mUserID;
    mUserName = app.mUserName;
    mUserEmail =app.mUserEmail;
    
    if (!app.onceInitFlag) {
        app.onceInitFlag = true;
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text = @"Loading...";
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             
             if (!error) {
                 currentEmail = [[[FIRAuth auth] currentUser] email];
                 NSLog(@"fetched user:%@  and Email : %@", result,result[@"email"]);
                 NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal",result[@"id"]]];
                 
                 (result[@"email"] != nil) ? mUserEmail = result[@"email"] : @"";
                 (result[@"id"]) ? mUserID = result[@"id"] : @"";
                 (result[@"name"]) ? mUserName = result[@"name"] : @"";
                 
                 app.mUserName = mUserName;
                 app.mUserEmail = currentEmail;
                 app.mUserID = mUserID;
                 
                 [userName setText: [@"Name  : " stringByAppendingString: mUserName]];
                 [userid setText: [  @"UserID: " stringByAppendingString: mUserID]];
                 [userEmail setText: [@"Email : " stringByAppendingString: currentEmail]];
                 
                 dispatch_async(dispatch_get_global_queue(0,0), ^{
                     NSData  *data = [NSData dataWithContentsOfURL:url];
                     if ( data == nil )
                         return;
                     dispatch_async(dispatch_get_main_queue(), ^{
                         // WARNING: is the cell still using the same data by this point??
                         app.mFBProfile = [UIImage imageWithData: data];
                         hud.hidden = YES;
                         [app addMFSideMenu];
                     });
                 });
                 
             } else
                 [self showMessagePrompt: error.localizedDescription];
         }];
        
    } else
    {
        [userName setText: [@"Name  : " stringByAppendingString: mUserName]];
        [userid setText: [  @"UserID: " stringByAppendingString: mUserID]];
        [userEmail setText: [@"Email : " stringByAppendingString: mUserEmail]];
    }
    
    
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView1{
    
    int fontSize = 100;
    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'", fontSize];
    [webView1 stringByEvaluatingJavaScriptFromString:jsString];
    
}
- (IBAction)showTransactions_optional:(id)sender {
    
    if (!app.showChatFlag) {
        app.showChatFlag = !app.showChatFlag;
        // show transactionView
        transactionView.hidden = NO;
        socialView.hidden = YES;
        bottomLabelView.hidden = YES;
    } else
    {
        app.showChatFlag = !app.showChatFlag;
        // hide transactionView
        transactionView.hidden = YES;
        socialView.hidden = NO;
        bottomLabelView.hidden = NO;
    }
    
}

- (void) initProfilePage
{
    // show TransactionView if there are data in Transactions
    
    [table_view registerNib: [UINib nibWithNibName: @"CustomTableFinancialAccountsTableViewCell" bundle:nil] forCellReuseIdentifier: @"cell_financial"];
    shopperCategoriesAmounts = [[NSArray alloc] init];
    arrayItems = [[NSArray alloc] init];
    
    
    [self retrievTransactions];
    
}

- (void) retrievTransactions
{
    FIRDatabaseReference *dbRef;
    NSString *userID = [[[FIRAuth auth] currentUser] uid];
    [self showProgressBar: @"Loading..."];
    dbRef = [[[[FIRDatabase database] reference] child: userID] child: @"financial_db"];
    if (dbRef != nil) {
        
        [dbRef observeSingleEventOfType:(FIRDataEventTypeValue) withBlock: ^(FIRDataSnapshot *_Nonnull snapshot) {
            hud.hidden = YES;
            if ([snapshot exists]) {
                
                for (snapshot in snapshot.children) {
                    NSDictionary *dic = snapshot.value;
                    NSArray *transactionsArray = [dic objectForKey: @"transactions"];
                    int sizeOfSameTransactions[6] = {0,0,0,0,0,0};
                    long amountOfSameTransactions[6] = {0,0,0,0,0,0};
                    
                    if (transactionsArray != nil) {
                        NSArray *arr = (NSArray *)[dic objectForKey: @"transactions"];
                        
                        // get counts of transactions
                        for (int i=0; i<arr.count; i++) {
                            NSDictionary *everyTransaction = [arr objectAtIndex:i];
                            
                            NSString *transactionName = [everyTransaction objectForKey: @"name"];
                            long transactionAmount = [[everyTransaction objectForKey: @"amount"] longValue];
                            NSString *transactionDate = [everyTransaction objectForKey: @"date"];
                            
                            if ([transactionName isEqualToString: @"Pharmacy"]) {
                                sizeOfSameTransactions[0]++;
                                amountOfSameTransactions[0]+= transactionAmount;
                            } else if ([transactionName isEqualToString: @"Home"]) {
                                sizeOfSameTransactions[1]++;
                                amountOfSameTransactions[1]+= transactionAmount;
                            }else if ([transactionName isEqualToString: @"Travel"]) {
                                sizeOfSameTransactions[2]++;
                                amountOfSameTransactions[2]+= transactionAmount;
                            }else if ([transactionName isEqualToString: @"Entertainment"]) {
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
                        dic_pharmacy = nil;
                        dic_home = nil;
                        dic_travel = nil;
                        dic_entertainment = nil;
                        dic_other = nil;
                        NSMutableArray *arr_temp = [[NSMutableArray alloc] init];
                        if (sizeOfSameTransactions[0]) {
                            dic_pharmacy = [NSDictionary dictionaryWithObjectsAndKeys: @"pharmacy_icon", @"icon",
                                            @"Pharmacy", @"category",
                                            [NSString stringWithFormat: @"%d Transactions", sizeOfSameTransactions[0]], @"counts",
                                            [NSString stringWithFormat: @"$ %lu", amountOfSameTransactions[0]], @"amount", nil];
                            [arr_temp addObject: dic_pharmacy];
                        } else if (sizeOfSameTransactions[1]) {
                            dic_home = [NSDictionary dictionaryWithObjectsAndKeys: @"home_icon", @"icon",
                                        @"Home", @"category",
                                        [NSString stringWithFormat: @"%d Transactions", sizeOfSameTransactions[1]], @"counts",
                                        [NSString stringWithFormat: @"$ %lu", amountOfSameTransactions[1]], @"amount", nil];
                            [arr_temp addObject: dic_home];
                        } else if (sizeOfSameTransactions[2]) {
                            dic_travel = [NSDictionary dictionaryWithObjectsAndKeys: @"travel_icon", @"icon",
                                          @"Travel", @"category",
                                          [NSString stringWithFormat: @"%d Transactions", sizeOfSameTransactions[2]], @"counts",
                                          [NSString stringWithFormat: @"$ %lu", amountOfSameTransactions[2]], @"amount", nil];
                            [arr_temp addObject: dic_travel];
                        } else if (sizeOfSameTransactions[3]) {
                            dic_entertainment = [NSDictionary dictionaryWithObjectsAndKeys: @"entertainment_icon", @"icon",
                                                 @"Entertainment", @"category",
                                                 [NSString stringWithFormat: @"%d Transactions", sizeOfSameTransactions[3]], @"counts",
                                                 [NSString stringWithFormat: @"$ %lu", amountOfSameTransactions[3]], @"amount", nil];
                            [arr_temp addObject: dic_entertainment];
                        } else
                        {
                            dic_other = [NSDictionary dictionaryWithObjectsAndKeys: @"other_icon", @"icon",
                                         @"Other", @"category",
                                         [NSString stringWithFormat: @"%d Transactions", sizeOfSameTransactions[4]], @"counts",
                                         [NSString stringWithFormat: @"$ %lu", amountOfSameTransactions[4]], @"amount", nil];
                            [arr_temp addObject: dic_other];
                        }
                        
                        
                        
                        shopperCategoriesAmounts = [[NSArray alloc] initWithArray: arr_temp];
                        
                        arrayItems = [barChartView createChartDataWithTitles:[NSArray arrayWithObjects:@"Pharmacy", @"Home", @"Travel", @"Entertainment", @"Other", nil]
                                                                      values:[NSArray arrayWithObjects:
                                                                              [NSString stringWithFormat: @"%lu", amountOfSameTransactions[0]],
                                                                              [NSString stringWithFormat: @"%lu", amountOfSameTransactions[1]],
                                                                              [NSString stringWithFormat: @"%lu", amountOfSameTransactions[2]],
                                                                              [NSString stringWithFormat: @"%lu", amountOfSameTransactions[3]],
                                                                              [NSString stringWithFormat: @"%lu", amountOfSameTransactions[4]], nil]
                                                                      colors:[NSArray arrayWithObjects:@"000000", @"000000", @"000000", @"000000", @"000000", nil]
                                                                 labelColors:[NSArray arrayWithObjects:@"FFFFFF", @"FFFFFF", @"FFFFFF", @"FFFFFF", @"FFFFFF", nil]];
                        
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
                               shouldPlotVerticalLines:YES];
                        
                        [table_view reloadData];
                    }
                }
                
                // show transactionView
                transactionView.hidden = NO;
                socialView.hidden = YES;
                bottomLabelView.hidden = YES;
                
                
            } else
            {
                // hide transactionView
                transactionView.hidden = YES;
                socialView.hidden = NO;
                bottomLabelView.hidden = NO;
            }
        }];
        
    } else
    {
        // hide transactionView
        transactionView.hidden = YES;
        socialView.hidden = NO;
        bottomLabelView.hidden = NO;
    }
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
    cell.mAmounts.text = [dic objectForKey: @"amount"];
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
        socialView.hidden = NO;
        bottomLabelView.hidden = NO;
        merchantAccountFeedbackView.hidden = YES;
        mScrollViewMerchantAccounts.hidden = NO;
        oldScrollviewFrame = mScrollViewMerchantAccounts.frame;
        if (app.isSelectedPlusButtonForHome) {
            [mMerchantHome.view removeFromSuperview];
            mMerchantHome = [[MerchantHome alloc] initWithNibName: @"MerchantHome" bundle: nil];
            mMerchantHome.view.frame = CGRectMake(oldScrollviewFrame.origin.x, 0, oldScrollviewFrame.size.width, oldScrollviewFrame.size.height);
            [mScrollViewMerchantAccounts addSubview: mMerchantHome.view];
        } else
        {
            // return to Pharmacy
            [mMerchantPharmacy.view removeFromSuperview];
            
            mMerchantPharmacy = [[MerchantPharmacy alloc] initWithNibName: @"MerchantPharmacy" bundle: nil];
            mMerchantPharmacy.view.frame = CGRectMake(self.view.frame.size.width, 0, oldScrollviewFrame.size.width, oldScrollviewFrame.size.height);
            [mScrollViewMerchantAccounts addSubview:mMerchantPharmacy.view];
        }
        
        mScrollViewMerchantAccounts.contentMode = UIViewContentModeScaleToFill;
        
    } else
    {
        // hide social and label (privacy and feedback label)
        socialView.hidden = YES;
        bottomLabelView.hidden = YES;
        
        // open FeedbackView
        // add FeedbackView
        MerchantAccountRateReviewsViewController *mFeedbackView;
        if (app.onceInitFlag) {
            mFeedbackView = [self.storyboard instantiateViewControllerWithIdentifier:@"feedbackView"];
            
            [self addChildViewController: mFeedbackView];
            mFeedbackView.view.frame = merchantAccountFeedbackView.frame;
            [merchantAccountFeedbackView addSubview: mFeedbackView.view];
            [mFeedbackView didMoveToParentViewController: self];
        }
        
        merchantAccountFeedbackView.hidden = NO;
        mScrollViewMerchantAccounts.hidden = YES;
    }
    
}

- (void) initMerchantAccountsScrollView
{
    testButtonFlag = false;
    merchantAccountFeedbackView.hidden = YES;
    mScrollViewMerchantAccounts.hidden = NO;
    
    // add notification target for add_button in TableView
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openFeedbackView:)
                                                 name:@"AddButtonPressed"
                                               object:nil];
    
    currentX = 0.0f;
    oldScrollviewFrame = mScrollViewMerchantAccounts.frame;
    // add View to ScrollView
//    CGFloat widthOfScrollView = mScrollViewMerchantAccounts.frame.size.width;
//    CGFloat heightOfScrollView = mScrollViewMerchantAccounts.frame.size.height;
    mMerchantHome = [[MerchantHome alloc] initWithNibName: @"MerchantHome" bundle:nil];
    [self addChildViewController:mMerchantHome];

    mMerchantHome.view.frame = CGRectMake(oldScrollviewFrame.origin.x, 0, oldScrollviewFrame.size.width, oldScrollviewFrame.size.height);
    [mScrollViewMerchantAccounts addSubview: mMerchantHome.view];
    [mMerchantHome didMoveToParentViewController:self];
    
    mMerchantPharmacy = [[MerchantPharmacy alloc] initWithNibName: @"MerchantPharmacy" bundle: nil];
    
    mMerchantPharmacy.view.frame = CGRectMake(self.view.frame.size.width, 0, oldScrollviewFrame.size.width, oldScrollviewFrame.size.height);
    [self addChildViewController:mMerchantPharmacy];
    [mScrollViewMerchantAccounts addSubview:mMerchantPharmacy.view];
    [mMerchantPharmacy didMoveToParentViewController: self];
    offSetX = self.view.frame.size.width;
    mScrollViewMerchantAccounts.contentSize = CGSizeMake(self.view.frame.size.width * 2,  mScrollViewMerchantAccounts.frame.size.height);
    mScrollViewMerchantAccounts.pagingEnabled = YES;
//    mScrollViewMerchantAccounts.autoresizesSubviews = YES;
    mScrollViewMerchantAccounts.contentMode = UIViewContentModeScaleToFill;
    
    [mPhamacyButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
    [mHomeButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
}

- (IBAction)didSelectPhamacy:(id)sender {
    UIButton *selectedButton = (UIButton *) sender;
    if (selectedButton.tag == 10) { // tapped Phamacy
        if (currentX == 0) {
            [mScrollViewMerchantAccounts setContentOffset:CGPointMake(offSetX, 0) animated:YES];
            currentX = offSetX;
        }
        
        [mPhamacyButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [mHomeButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
    } else // tapped Home
    {
        if (currentX == offSetX) {
            [mScrollViewMerchantAccounts setContentOffset:CGPointMake(0, 0) animated:YES];
            currentX = 0;
        }
        
        [mPhamacyButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
        [mHomeButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    currentX = mScrollViewMerchantAccounts.contentOffset.x;
    if (currentX == 0) {
        [mPhamacyButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
        [mHomeButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        
    } else
    {
        [mPhamacyButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
        [mHomeButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
        offSetX = currentX;
        
    }
    
    
    NSLog( @"ENDED----- %f", currentX);

}

- (void) addPlaidAPIViewController
{
    PlaidAPIViewController *mPlaidApiViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"plaidApiViewController"];
    
    [self addChildViewController: mPlaidApiViewController];
    mPlaidApiViewController.view.frame = CGRectMake(0, 0, _financialAccountsView.frame.size.width, _financialAccountsView.frame.size.height);
    [_financialAccountsView addSubview: mPlaidApiViewController.view];
    [mPlaidApiViewController didMoveToParentViewController: self];
}

- (void) imageViewGesture
{
    UITapGestureRecognizer *tapTwitter, *tapInstagram, *tapFaceBook;
    tapTwitter = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(actionTwitter)];
    [imv_twitter addGestureRecognizer:tapTwitter];
    
    tapInstagram = [[UITapGestureRecognizer alloc]
                  initWithTarget:self
                  action:@selector(actionInstagram)];
    [imv_instagram addGestureRecognizer:tapInstagram];
    
    tapFaceBook = [[UITapGestureRecognizer alloc]
                  initWithTarget:self
                  action:@selector(actionFaceBook)];
    [imv_facebook addGestureRecognizer:tapFaceBook];
}

- (void) gotoPrivacyPolicy
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.zealplatform.com/privacy"]];
}

- (void) gotoFeedback
{
    NSLog(@"pressed");
}

- (void) actionTwitter
{
    NSLog(@"pressed");
}

- (void) actionInstagram
{
    NSLog(@"pressed");
}

- (void) actionFaceBook
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
