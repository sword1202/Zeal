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
#import "SquareHttpClient.h"
#import "CustomTableFinancialAccountsTableViewCell.h"
#import "TWRChart.h"
//@import FBSDKCoreKit;
@import GoogleSignIn;

@interface MainViewController ()
{
    bool menuFlag, profileFlag, merchantAccountsFlag, financialAccountsFlag, aboutFlag, testButtonFlag;
    // profileView
    __weak IBOutlet UILabel *privacyPolicyLabel;
    __weak IBOutlet UILabel *feedbackLabel;
    
    __weak IBOutlet UIView *bottomLabelView;
    
    NSArray *shopperCategoriesAmounts;
    NSMutableArray *arrForLineGraphData, *arrForLineGraphDataLastMonth;
    NSMutableDictionary *monthlySpendMoney, *monthlyCreditMoney;
    NSArray *arrayItems;
    __weak IBOutlet UIView *transactionView;
    
    __weak IBOutlet UILabel *mVerticalTextLabel;
    
    // Merchant Accounts View
    
    SquareHttpClient *httpClientSquareup;
    NSMutableArray *currentCoffeelists;
    NSArray *catalogItemsFromSquareup;
    
    __weak IBOutlet UIButton *mEatingButton;
    __weak IBOutlet UIButton *mShopsButton;
    __weak IBOutlet UIButton *mCoffeeButton;
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
    
    __weak IBOutlet UILabel *name_label;
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
        _chartView = [[TWRChartView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _chartContainerView.frame.size.height)];
        _chartView.backgroundColor = [UIColor clearColor];
        [_chartContainerView addSubview: _chartView];
        httpClientSquareup = [SquareHttpClient sharedSquareHttpClient];
        
        app = (AppDelegate *) [UIApplication sharedApplication].delegate;
        [self handleWithUserLoggedInFB];
        
    }
    
}

- (void) handleWithUserLoggedInFB
{
    [self.navigationController setNavigationBarHidden:NO];
    
//    [self.navigationController.navigationBar setShadowImage: [UIImage imageNamed: @"shadow_background"]];
//    self.navigationController.navigationBar.layer.shadowColor = [[UIColor clearColor] CGColor];
//    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
//    self.navigationController.navigationBar.layer.shadowRadius = 3.0f;
//    self.navigationController.navigationBar.layer.shadowOpacity = 1.0f;
    
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
        
        NSString *firstName = [[mUserName componentsSeparatedByString:@" "] objectAtIndex:0];
        [name_label setText: [@"Hello, " stringByAppendingString: firstName]];
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
        if ([[FIRAuth auth] currentUser] != nil) {
            mUserName = [[[FIRAuth auth] currentUser] displayName];
            NSString *firstName = [[mUserName componentsSeparatedByString:@" "] objectAtIndex:0];
            [name_label setText: [@"Hello, " stringByAppendingString: firstName]];
        }
        
        app.mFBProfile = [UIImage imageWithData: mData];
        
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
    
    [self handleCoffeeLists];
    
    [self retrieveTransaction];
}

- (void) handleCoffeeLists
{
    // get catalog items from squareup
    catalogItemsFromSquareup = [[NSArray alloc] init];
    [httpClientSquareup downloadSquareupItemsWithCompletionHandler:^(NSArray *items) {
        catalogItemsFromSquareup = items;
    }];
    
    // add order items in categorylist
    
    // // first retrieve coffeelist
    
    FIRDatabaseReference *mCoffeeListDBReference = [[[FIRDatabase database] reference] child: kcoffeelist];
    
    if (mCoffeeListDBReference != nil) {
        //        [ToastHelper showLoading: self.view message: @"Loading ..."];
        [mCoffeeListDBReference observeSingleEventOfType:(FIRDataEventTypeValue) withBlock: ^(FIRDataSnapshot *_Nonnull snapshot) {

            if ([snapshot exists]) {
                
                currentCoffeelists = [[NSMutableArray alloc] initWithArray: snapshot.value];
                
                // get catagory items from squareup
                
                [httpClientSquareup downloadSquareupCategoryWithCompletionHandler:^(NSArray *items) {
                    for (int i = 0; i < items.count; i ++) {
                        NSDictionary *everyCategory = [items objectAtIndex: i];
                        NSString *categoryID = [everyCategory objectForKey: @"id"];
                        NSDictionary *categoryDataDic = [everyCategory objectForKey: @"category_data"];
                        NSString *categoryName = [categoryDataDic objectForKey: @"name"];

                        // compare category name from firebase
                        
                        // get category name from firebase
                        for (int j=0; j<[currentCoffeelists count]; j++) {
                            NSDictionary *everyCoffeeList = [currentCoffeelists objectAtIndex: j];
                            CoffeeObj *obj = [[CoffeeObj alloc] initWithDic: everyCoffeeList];
                            NSMutableArray *orderlists = [NSMutableArray new];
                            if ([categoryName isEqualToString: obj.name] && ![CommonUtils isNull: catalogItemsFromSquareup]) {
                                // create orderlists
                                  // find items for same category id
                                for (int k=0; k<[catalogItemsFromSquareup count]; k++) {
                                    NSDictionary *everyItem = [catalogItemsFromSquareup objectAtIndex: k];
                                    NSDictionary *itemData = [everyItem objectForKey: @"item_data"];
                                    NSString *currentCategoryID = [itemData objectForKey: @"category_id"];
                                    if (![CommonUtils isNull: currentCategoryID] && [currentCategoryID isEqualToString: categoryID]) {
                                        [orderlists addObject: [itemData objectForKey: @"name"]];
                                    }
                                }
                                
                                // add orderlist to currentCoffeeLists
                                obj.orderLists = [orderlists copy];
                                [currentCoffeelists replaceObjectAtIndex: j withObject: obj.dicObject];
                            }
                            
                        }
                        
                        // update firebase
                        [mCoffeeListDBReference setValue:currentCoffeelists];
                    }
                }];
                
                
                
                
                
//                [self getItemsFromSquareup];
                
            }
        }];
    }
    
}

- (void) retrieveTransaction
{
    
    FIRDatabaseReference *dbRef;
    NSString *userID;
    userID = TEST_MODE==1 ? UID:[[[FIRAuth auth] currentUser] uid];
    
    dbRef = [[[[[FIRDatabase database] reference] child:@"consumers"] child: userID] child: kFINANCIAL_DB];
    if (dbRef != nil) {
        [self showProgressBar: @"Retrieving Transactions..."];
        [dbRef observeSingleEventOfType:(FIRDataEventTypeValue) withBlock: ^(FIRDataSnapshot *_Nonnull snapshot) {
            hud.hidden = YES;
            if ([snapshot exists]) {
                
                [self handleSnapShot: snapshot];
                [self loadLineChart];
                
                // show transactionView
                transactionView.hidden = NO;
                bottomLabelView.hidden = YES;
                
                
                
                
                
            } else
            {
                // hide transactionView
                transactionView.hidden = YES;
                bottomLabelView.hidden = YES;
            }
        } withCancelBlock:^(NSError * _Nonnull error) {
            hud.hidden = YES;
            NSLog(@"%@", error.localizedDescription);
        }];
        
    } else
    {
        // hide transactionView
        transactionView.hidden = YES;
        bottomLabelView.hidden = YES;
    }
}

- (void) handleSnapShot: (FIRDataSnapshot *_Nonnull) snapshot
{
    monthlySpendMoney = [[NSMutableDictionary alloc] init];
    monthlyCreditMoney = [[NSMutableDictionary alloc] init];
    CGFloat amountOfSameTransactions[6] = {0,0,0,0,0,0};
    
    NSString *currentMonthKey = [CommonUtils getMonthKey: [self getDateTime:0 format: @"m"]];
    
    for (snapshot in snapshot.children) { // loop in all institution id (bank accounts)
        
        NSDictionary *dic = snapshot.value;
        
        NSDictionary *monthlyTransactions = [dic objectForKey: kmonthly];
        
        NSArray *keys = [monthlyTransactions allKeys];
        
        for (int kk=0; kk<keys.count; kk++) {
            NSString *mKey = [keys objectAtIndex: kk];
            
            NSArray *transactionArray = [monthlyTransactions objectForKey: mKey];
            for (int i=0; i<transactionArray.count; i++)
            {
                NSDictionary *everyTransaction = [transactionArray objectAtIndex: i];
                CGFloat transactionAmount = [[everyTransaction objectForKey: @"amount"] doubleValue];
                CGFloat oldValue = 0;
                
                //                handle spend and credit money
                if (transactionAmount > 0) {
                    // spending money
                    if ([monthlySpendMoney objectForKey: mKey] != nil && ![[monthlySpendMoney objectForKey: mKey] isEqual: [NSNull null]]) {
                        oldValue = [[monthlySpendMoney objectForKey: mKey] floatValue];
                        transactionAmount += oldValue;
                        [monthlySpendMoney setObject: [NSNumber numberWithFloat: transactionAmount] forKey: mKey];
                    } else
                        [monthlySpendMoney setObject: [NSNumber numberWithFloat: transactionAmount] forKey: mKey];
                } else
                {
                    // credit money
                    if ([monthlyCreditMoney objectForKey: mKey] != nil && ![[monthlyCreditMoney objectForKey: mKey] isEqual: [NSNull null]]) {
                        oldValue = [[monthlyCreditMoney objectForKey: mKey] floatValue];
                        transactionAmount += oldValue;
                        [monthlyCreditMoney setObject: [NSNumber numberWithFloat: transactionAmount] forKey: mKey];
                    } else
                        [monthlyCreditMoney setObject: [NSNumber numberWithFloat: transactionAmount] forKey: mKey];
                }
                
                //                handle spend and credit money
                
                
                
                if (![mKey isEqualToString: currentMonthKey]) {
                    continue;
                }
                
                // handle data for tableview
                
                
                //                currentMonth = @"01";
                
                // calculate spending money for only this month
                NSArray *category = [everyTransaction objectForKey: @"category"];
                NSString *storeName = [everyTransaction objectForKey: @"name"]; // sub categories in each Store(Shops, Eating)
                // add categories for shops and eating and create DB -
                
                NSString *transactionName; // Stores like Shops and FoodAndDrink(Eating)
                if (category != nil) {
                    transactionName = [category objectAtIndex: 0];
                } else
                    transactionName = @"other";
                
                //
                BOOL isExist = false;
                if ([transactionName isEqualToString: @"Shops"]) {
                    // Shops
                    
                    for ( int i = 0; i < app.arrMerchantShops.count; i++) {
                        if ([storeName isEqualToString: [app.arrMerchantShops objectAtIndex:i]]) {
                            isExist = true;
                        }
                    }
                    
                    if (!isExist) {
                        [app.arrMerchantShops addObject: storeName];
                    }
                    
                } else if ([transactionName isEqualToString: @"Food and Drink"]) {
                    // Eating
                    
                    for ( int i = 0; i < app.arrMerchantEatings.count; i++) {
                        if ([storeName isEqualToString: [app.arrMerchantEatings objectAtIndex:i]]) {
                            isExist = true;
                        }
                    }
                    if (!isExist) {
                        [app.arrMerchantEatings addObject: storeName];
                    }
                    
                }
                
                CGFloat amount = [[everyTransaction objectForKey: @"amount"] doubleValue];
                
                if (amount > 0) {
                    if ([transactionName isEqualToString: @"Shops"]) {
                        amountOfSameTransactions[0]+= amount;
                    } else if ([transactionName isEqualToString: @"Food and Drink"]) {
                        amountOfSameTransactions[1]+= amount;
                    }else if ([transactionName isEqualToString: @"Travel"]) {
                        amountOfSameTransactions[2]+= amount;
                    }else if ([transactionName isEqualToString: @"Service"]) {
                        amountOfSameTransactions[3]+= amount;
                    } else
                    {
                        // other
                        amountOfSameTransactions[4]+= amount;
                    }
                }
                // handle data for tableview
                ////////
                
            }
        }
     
    }
    
    // tableview handle

    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    NSMutableArray *arr = [[NSMutableArray alloc]  init];
    
    NSString *formatted = [formatter stringFromNumber: [NSNumber numberWithFloat: amountOfSameTransactions[0]]];
    [arr addObject: [NSDictionary dictionaryWithObjectsAndKeys:
                     @"Shops", @"category",
                     [@"$" stringByAppendingString: formatted], @"amount", nil]];
    
    formatted = [formatter stringFromNumber: [NSNumber numberWithFloat: amountOfSameTransactions[1]]];
    [arr addObject: [NSDictionary dictionaryWithObjectsAndKeys:
                     @"Food and Drink", @"category",
                     [@"$" stringByAppendingString: formatted], @"amount", nil]];
    
    formatted = [formatter stringFromNumber: [NSNumber numberWithFloat: amountOfSameTransactions[2]]];
    [arr addObject: [NSDictionary dictionaryWithObjectsAndKeys:
                     @"Travel", @"category",
                     [@"$" stringByAppendingString: formatted], @"amount", nil]];
    
    formatted = [formatter stringFromNumber: [NSNumber numberWithFloat: amountOfSameTransactions[3]]];
    [arr addObject: [NSDictionary dictionaryWithObjectsAndKeys:
                     @"Service", @"category",
                     [@"$" stringByAppendingString: formatted], @"amount", nil]];
    
    formatted = [formatter stringFromNumber: [NSNumber numberWithFloat: amountOfSameTransactions[4]]];
    [arr addObject: [NSDictionary dictionaryWithObjectsAndKeys:
                     @"Other", @"category",
                     [@"$" stringByAppendingString: formatted], @"amount", nil]];
    

    shopperCategoriesAmounts = [[NSArray alloc] initWithArray: arr];
    
    [table_view reloadData];
}

- (void)loadLineChart {
    
    NSString *currentMonth = [self getDateTime:0 format: @"m"];
//    currentMonth = @"01";
    CGFloat sendingAmount = [[monthlySpendMoney objectForKey: [CommonUtils getMonthKey: currentMonth]] doubleValue];
    CGFloat creditAmount = [[monthlyCreditMoney objectForKey: [CommonUtils getMonthKey: currentMonth]] doubleValue];
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSString *formatted = [formatter stringFromNumber: [NSNumber numberWithFloat: sendingAmount]];
    
    if (sendingAmount == 0) {
        _monthlySendAmountLabel.text = @"$0.00";
    } else
        _monthlySendAmountLabel.text =[@"$" stringByAppendingString: formatted];
    
    
    if (creditAmount == 0) {
        _monthlyCreditAmountLabel.text = @"$0.00";
    } else
    {
        NSString *formatted = [formatter stringFromNumber: [NSNumber numberWithFloat: -1*creditAmount]];
        _monthlyCreditAmountLabel.text = [@"$" stringByAppendingString: formatted];
    }
    
    NSMutableArray *spendMoneyDataPoints = [[NSMutableArray alloc] init];
    
    // Build chart data
    [spendMoneyDataPoints addObject: [CommonUtils getAmountFromDic:monthlySpendMoney key:@"Jan"]];
    [spendMoneyDataPoints addObject: [CommonUtils getAmountFromDic:monthlySpendMoney key:@"Feb"]];
    [spendMoneyDataPoints addObject: [CommonUtils getAmountFromDic:monthlySpendMoney key:@"Mar"]];
    [spendMoneyDataPoints addObject: [CommonUtils getAmountFromDic:monthlySpendMoney key:@"Apr"]];
    [spendMoneyDataPoints addObject: [CommonUtils getAmountFromDic:monthlySpendMoney key:@"May"]];
    [spendMoneyDataPoints addObject: [CommonUtils getAmountFromDic:monthlySpendMoney key:@"Jun"]];
    [spendMoneyDataPoints addObject: [CommonUtils getAmountFromDic:monthlySpendMoney key:@"Jul"]];
    [spendMoneyDataPoints addObject: [CommonUtils getAmountFromDic:monthlySpendMoney key:@"Aug"]];
    [spendMoneyDataPoints addObject: [CommonUtils getAmountFromDic:monthlySpendMoney key:@"Sep"]];
    [spendMoneyDataPoints addObject: [CommonUtils getAmountFromDic:monthlySpendMoney key:@"Oct"]];
    [spendMoneyDataPoints addObject: [CommonUtils getAmountFromDic:monthlySpendMoney key:@"Nov"]];
    [spendMoneyDataPoints addObject: [CommonUtils getAmountFromDic:monthlySpendMoney key:@"Dec"]];
  
    TWRDataSet *moneyValues = [[TWRDataSet alloc] initWithDataPoints: spendMoneyDataPoints fillColor: [UIColor clearColor] strokeColor: [UIColor whiteColor] pointColor: [UIColor whiteColor] pointStrokeColor: [UIColor clearColor]];
    
    NSArray *labels = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun",
                        @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];
    
    TWRLineChart *line = [[TWRLineChart alloc] initWithLabels:labels
                                                     dataSets:@[moneyValues]
                                                     animated: YES];
    // Load data
    [_chartView loadLineChart:line];

}

- (NSString *) getDateTime: (int) pastDays format: (NSString *) mFormat
{
    //    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    
    NSDate *todayDate = [NSDate date];
    NSTimeInterval timeInterval = -pastDays*24*60*60;
    NSDate *pastDate = [todayDate dateByAddingTimeInterval: timeInterval];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    if (mFormat == nil) {
        [dateFormat setDateFormat:@"yyy-MM-dd"];
    }
    else if ([mFormat isEqualToString: @"y"]) {
        [dateFormat setDateFormat:@"yyy"];
    } else if ([mFormat isEqualToString: @"m"])
    {
        [dateFormat setDateFormat:@"MM"];
    } else if ([mFormat isEqualToString: @"d"])
    {
        [dateFormat setDateFormat:@"dd"];
    }
    
    [dateFormat setTimeZone: [NSTimeZone localTimeZone]];
    NSString *strOfDate = [dateFormat stringFromDate:pastDate];
    return strOfDate;
}

/*
 
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
        NSString *storeName = [everyTransaction objectForKey: @"name"]; // sub categories in each Store(Shops, Eating)
        // add categories for shops and eating and create DB -
        
        NSString *transactionName; // Stores like Shops and FoodAndDrink(Eating)
        if (category != nil) {
            transactionName = [category objectAtIndex: 0];
        } else
            transactionName = @"other";
        
        //
        BOOL isExist = false;
        if ([transactionName isEqualToString: @"Shops"]) {
            // Shops
            
            for ( int i = 0; i < app.arrMerchantShops.count; i++) {
                if ([storeName isEqualToString: [app.arrMerchantShops objectAtIndex:i]]) {
                    isExist = true;
                }
            }
            if (!isExist) {
                [app.arrMerchantShops addObject: storeName];
            }
            
        } else if ([transactionName isEqualToString: @"Food and Drink"]) {
            // Eating
            
            for ( int i = 0; i < app.arrMerchantEatings.count; i++) {
                if ([storeName isEqualToString: [app.arrMerchantEatings objectAtIndex:i]]) {
                    isExist = true;
                }
            }
            if (!isExist) {
                [app.arrMerchantEatings addObject: storeName];
            }
            
        }
        //
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
    /* -------
     arrayItems = [barChartView createChartDataWithTitles:[NSArray arrayWithObjects:@"Pharmacy", @"Home", @"Travel", @"Entertainment", @"Other", nil]
     values:[NSArray arrayWithObjects:
     amountForChart1,
     amountForChart2,
     amountForChart3,
     amountForChart4,
     amountForChart5, nil]
     colors:[NSArray arrayWithObjects:colorChart1, colorChart2, colorChart3, colorChart4, colorChart5, nil]
     labelColors:[NSArray arrayWithObjects:@"000000", @"000000", @"000000", @"000000", @"000000", nil]];
 
      qsort amounts
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
      draw chat
     Set the Shape of the Bars (Rounded or Squared) - Rounded is default
     [barChartView setupBarViewShape:BarShapeSquared];
 
     Set the Style of the Bars (Glossy, Matte, or Flat) - Glossy is default
     [barChartView setupBarViewStyle:BarStyleGlossy];
 
     Set the Drop Shadow of the Bars (Light, Heavy, or None) - Light is default
     [barChartView setupBarViewShadow:BarShadowLight];
 
     Generate the bar chart using the formatted data
     [barChartView setDataWithArray:arrayItems
     showAxis:DisplayBothAxes
     withColor:[UIColor whiteColor]
     shouldPlotVerticalLines:YES];
 /* -------
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

//- (NSString *)popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph {
//    return @" people";
//}

- (NSString *)popUpPrefixForlineGraph:(BEMSimpleLineGraphView *)graph {
    return @"$ ";
}

*/

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
    
    cell.plaid_main_list_view.hidden = YES;
    cell.logo_img.hidden = YES;
    CGRect rect = cell.logo_img.frame;
    rect.size.width = 0;
    cell.logo_img.frame = rect;
//    cell.logo_img_ChartView.image = [UIImage imageNamed: [dic objectForKey: @"icon"]];
    cell.logo_img_ChartView.hidden = YES;
    cell.minstitutionName.text = [dic objectForKey: @"category"];
//    cell.minstitutionName.text = [dic objectForKey: @"counts"];
    [self createBaseLineOfButton: cell.btn_add];
    cell.mLabelAccountName.text = [dic objectForKey: @"amount"];
    cell.mLabelAccountName.textColor = [UIColor whiteColor];
    cell.mAmounts.hidden = YES;
    cell.btn_add.hidden = NO;
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog( @"%d --- '%d'", (int)indexPath.row, (int)tableView.tag);
    [tableView deselectRowAtIndexPath: indexPath animated:YES];
    
}

- (void) createBaseLineOfButton: (UIButton *) button
{
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.borderColor = [UIColor whiteColor].CGColor;
    border.frame = CGRectMake(0, button.frame.size.height - borderWidth, button.frame.size.width, button.frame.size.height);
    border.borderWidth = borderWidth;
    [button.layer addSublayer: border];
    button.layer.masksToBounds = YES;

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
        bottomLabelView.hidden = YES;
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
    [self addMerchantCategories];
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
    
    
    offSetX = self.view.frame.size.width;
    mScrollViewMerchantAccounts.contentSize = CGSizeMake(self.view.frame.size.width * 3,  100);
//    mScrollViewMerchantAccounts.autoresizesSubviews = YES;
    mScrollViewMerchantAccounts.contentMode = UIViewContentModeScaleToFill;
    
    [mEatingButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
    [mShopsButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
    [mCoffeeButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
//    [mTravelButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
}

- (void) addMerchantCategories
{
    // Shops Items
    
    if (app.arrMerchantShops.count > 0) {
        [self updateDBForStores: @"Shops" categoryName: app.arrMerchantShops];
    }
    
    // Eating Items
    if (app.arrMerchantEatings.count > 0) {
        [self updateDBForStores: @"Eating" categoryName: app.arrMerchantEatings];
    }
    
}

- (void) updateDBForStores: (NSString *)mStoreName categoryName: (NSArray *) newCategories
{
    
    FIRDatabaseReference *dbRef;
    NSString *userID = TEST_MODE==1 ? UID:[[[FIRAuth auth] currentUser] uid];
    
    dbRef = [[[[[[FIRDatabase database] reference] child:@"consumers"] child: userID] child: @"stores_db"] child: mStoreName];
    if (dbRef != nil) {
        
        [dbRef observeSingleEventOfType:(FIRDataEventTypeValue) withBlock: ^(FIRDataSnapshot *_Nonnull snapshot) {
            if ([snapshot exists]) {
                NSMutableArray *existCategories = snapshot.value;
                BOOL isExist = false;
                for (int i = 0; i < newCategories.count; i++) { // new 1, 2, 3   exist: 2, 3 , 5
                    for (int j = 0; j < existCategories.count; j ++) {
                        if ([[newCategories objectAtIndex: i] isEqualToString: [existCategories objectAtIndex: j]]) {
                            // if categories already exists...
                            isExist = true;
                            j = (int)existCategories.count - 1;
                        }
                        
                        if ( j == existCategories.count - 1 && !isExist) {
                            [existCategories addObject: [newCategories objectAtIndex: i]];
                        } else
                        {
                            isExist = false;
                            
                        }
                    }
                    
                }
                
                [dbRef setValue: existCategories];
                [self initMerchantArray: mStoreName];
                
            } else
            {
                [dbRef setValue: newCategories];
                [self initMerchantArray: mStoreName];
            }
        }];
        
    } else
    {
        [dbRef setValue: newCategories];
        [self initMerchantArray: mStoreName];
        
    }
    
}

- (void) initMerchantArray: (NSString *) storeName
{
    if ([storeName isEqualToString: @"Shops"]) {
        app.arrMerchantShops = [[NSMutableArray alloc] initWithCapacity: 30];
    } else
    {
        app.arrMerchantEatings = [[NSMutableArray alloc] initWithCapacity: 30];
    }
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
        [mCoffeeButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
//        [mTravelButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
    } else if (selectedButton.tag == 20) // tapped Shops
    {
        
        if (currentX == 0 || currentX == 2*offSetX) {
            [mScrollViewMerchantAccounts setContentOffset:CGPointMake(offSetX, 0) animated:YES];
            currentX = offSetX;
        }
        
        
        
        [mEatingButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
        [mShopsButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        [mCoffeeButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
//        [mTravelButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
    } else if (selectedButton.tag == 30) // Eating
    {
        // tapped Eating
        if (currentX == 0 || currentX == offSetX) {
            [mScrollViewMerchantAccounts setContentOffset:CGPointMake(2*offSetX, 0) animated:YES];
            currentX = 2*offSetX;
        }
        
        [mEatingButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
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
        [mCoffeeButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
//        [mTravelButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
        
    } else if (currentX == offSetX)
    {
        [mEatingButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
        [mShopsButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        [mCoffeeButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
//        [mTravelButton setTitleColor: [UIColor grayColor] forState: UIControlStateNormal];
//        offSetX = currentX;
        
    } else if (currentX == 2*offSetX)
    {
        [mEatingButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
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
