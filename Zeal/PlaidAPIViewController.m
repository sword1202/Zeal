//
//  PlaidAPIViewController.m
//  Zeal
//
//  Created by P1 on 6/7/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import "PlaidAPIViewController.h"
#import "ToastHelper.h"
#import "CustomTableFinancialAccountsTableViewCell.h"
#import "PlaidHTTPClient.h"
#import "UIViewController+Alerts.h"
#import "MBProgressHUD.h"
@import Firebase;

// Key For Plaid API Integration
#define PLAID_PUBLIC_KEY @"667778757a11bac2a6ee9b156c914a"
#define ENV @"development" // production, development, sandbox
#define CLIENT_NAME @"ZEAL"
#define PRODUCTION @"transactions" // auth, transactions, balance, identity, income
#define TRANS_DELAY 12.0

@interface PlaidAPIViewController ()
{
    __weak IBOutlet UIButton *btn_linkWithPlaid;
    __weak IBOutlet UIButton *btn_addMoreBank;
    __weak IBOutlet UIView *tableViewContainer;
    NSMutableArray *arr_savedFinancialAccounts;
    NSArray *arr_everyTransactionsForBank;
    FIRDatabaseReference *dbRef;
    PlaidHTTPClient *httpClientPlaid;
    // params of Cell
    NSDictionary *saveDic;
    MBProgressHUD *hud;
    NSString *sel_institution_id;
    NSString *lastYear, *lastMonth, *lastMonthStartDate,* lastMonthEndDate,
            *currentYear, *currentMonth, *currentStartDate, *currentEndDate;
}
@end

@implementation PlaidAPIViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(didReceiveNotification:)
//                                                 name:@"PLDPlaidLinkSetupFinished"
//                                               object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _webview.hidden = YES;
    
    [table_view registerNib: [UINib nibWithNibName: @"CustomTableFinancialAccountsTableViewCell" bundle:nil] forCellReuseIdentifier: @"cell_financial"];
    
    [tableViewOfTransactions registerNib: [UINib nibWithNibName: @"CustomTableFinancialAccountsTableViewCell" bundle:nil] forCellReuseIdentifier: @"cell_financial"];
    
    tableViewOfTransactions.hidden = YES;
    
    [self retreiveDataFromDB];
    [self createBaseLineOfButton];
    
    // initialize PlaidClientHttp to retrieve transactions
    httpClientPlaid = [PlaidHTTPClient sharedPlaidHTTPClient];
}

- (void) createBaseLineOfButton
{
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.borderColor = [UIColor blueColor].CGColor;
    border.frame = CGRectMake(0, btn_linkWithPlaid.frame.size.height - borderWidth, btn_linkWithPlaid.frame.size.width, btn_linkWithPlaid.frame.size.height);
    border.borderWidth = borderWidth;
    [btn_linkWithPlaid.layer addSublayer: border];
    btn_linkWithPlaid.layer.masksToBounds = YES;
    
    //
    CALayer *border1 = [CALayer layer];
    border1.borderColor = [UIColor blackColor].CGColor;
    border1.frame = CGRectMake(0, btn_addMoreBank.frame.size.height - borderWidth, btn_addMoreBank.frame.size.width, btn_addMoreBank.frame.size.height);
    border1.borderWidth = borderWidth;
    [btn_addMoreBank.layer addSublayer: border1];
    btn_addMoreBank.layer.masksToBounds = YES;
}

- (void) retreiveDataFromDB
{
    arr_savedFinancialAccounts = [[NSMutableArray alloc] init];
    NSString *userID = [[[FIRAuth auth] currentUser] uid];
    dbRef = [[[[FIRDatabase database] reference] child: userID] child: @"financial_db"];
    if (dbRef != nil) {
        
        [dbRef observeEventType:(FIRDataEventTypeValue) withBlock: ^(FIRDataSnapshot *_Nonnull snapshot) {
            if ([snapshot exists]) {
                arr_savedFinancialAccounts = [[NSMutableArray alloc] init];
                for (snapshot in snapshot.children) {
                    [arr_savedFinancialAccounts addObject:[snapshot value]];
                }
                tableViewContainer.hidden = NO;
                [table_view reloadData];
            } else
            {
                tableViewContainer.hidden = YES;
            }
        }];
        
    } else
    {
        tableViewContainer.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didConnectPlaidLink:(id)sender {
    
    if ([btn_addMoreBank.titleLabel.text isEqualToString: @"BACK"]) {
        [btn_addMoreBank setTitle: @"Add more banks" forState: UIControlStateNormal];
        tableViewOfTransactions.hidden = YES;
    } else
    {
        [self initWebViewForPlaid];
    }
    
}

- (void) initWebViewForPlaid
{
    _webview.hidden = NO;
    _webview.delegate = self;
    
    // Build a dictionary with the Link configuration options
    // See the Link docs (https://plaid.com/docs/link) for full documentation.
    
    NSDictionary* linkInitializationOptions = [[NSMutableDictionary alloc] init];
    [linkInitializationOptions setValue:PLAID_PUBLIC_KEY forKey:@"key"];
    [linkInitializationOptions setValue: PRODUCTION forKey:@"product"];
    [linkInitializationOptions setValue:ENV forKey:@"env"];
    [linkInitializationOptions setValue:@"false" forKey:@"selectAccount"];
    [linkInitializationOptions setValue:CLIENT_NAME forKey:@"clientName"];
    [linkInitializationOptions setValue:@"https://requestb.in" forKey:@"webhook"];
    [linkInitializationOptions setValue:@"https://cdn.plaid.com/link/v2/stable/link.html" forKey:@"baseUrl"];
    
    // Generate the Link initialization URL based off of the configuration settings
    NSURL* linkInitializationUrl = [self generateLinkInitializationURLWithOptions:linkInitializationOptions];
    
    // Load the Link initialization URL in the webview.
    // Link will start automatically
    [_webview loadRequest:[NSURLRequest requestWithURL:linkInitializationUrl]];
}

#pragma mark UITableViewDelegate & DataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger tableCellCount = arr_savedFinancialAccounts.count;
    if (tableView.tag == 200) {
        tableCellCount = arr_everyTransactionsForBank.count;
    }
    return tableCellCount;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableFinancialAccountsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell_financial" forIndexPath:indexPath];
    if (tableView.tag == 100) {
        NSDictionary *dic = [arr_savedFinancialAccounts objectAtIndex: indexPath.row];
        cell.mLabelAccountName.text = @"Plaid";
        cell.minstitutionName.text = [dic objectForKey: @"institution_name"];
        cell.logo_img_ChartView.hidden = YES;
//        UIImage *image = [UIImage imageNamed: [dic objectForKey: @"institution_id"]];
        //display general image
        UIImage *image = [UIImage imageNamed: @"plaid_logo"];
        if (image != nil) {
            cell.logo_img.image = image;
        }
    } else
    {
        NSDictionary *dic = [arr_everyTransactionsForBank objectAtIndex: indexPath.row];
        cell.logo_img_ChartView.hidden = YES;
        UIImage *image = [UIImage imageNamed: sel_institution_id];
        
        if (image != nil && indexPath.row == 0) {
            cell.logo_img.image = image;
            cell.logo_img.hidden = NO;
        } else
            cell.logo_img.hidden = YES;
        long amount = [[dic objectForKey: @"amount"] longValue];
        if (amount < 0) {
            amount = 0 - amount;
            cell.mAmounts.text = [NSString stringWithFormat: @"$ -%lu", amount];
//            cell.mAmounts.textColor = [UIColor redColor];
        } else
        {
            cell.mAmounts.text = [NSString stringWithFormat: @"$ %lu", amount];
//            cell.mAmounts.textColor = [UIColor blackColor];
        }
        
        cell.mLabelAccountName.text = [dic objectForKey: @"name"];
        cell.minstitutionName.text = [dic objectForKey: @"date"];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog( @"%d --- '%d'", (int)indexPath.row, (int)tableView.tag);
    [tableView deselectRowAtIndexPath: indexPath animated:YES];
    
    if (tableView.tag == 100) {
        NSDictionary *sel_dic = [arr_savedFinancialAccounts objectAtIndex: indexPath.row];
        sel_institution_id = [sel_dic objectForKey: @"institution_id"];
        [self retrievTransactions: [sel_dic objectForKey: @"institution_name"]];
        
    }
    
}

- (void) retrievTransactions: (NSString *) institutionName
{
    if ([[dbRef child: institutionName] child: @"transactions"] != nil) {
        
        [self showProgressBar: @"Loading..."];
        [[[dbRef child: institutionName] child: @"transactions"] observeSingleEventOfType:(FIRDataEventTypeValue) withBlock: ^(FIRDataSnapshot *_Nonnull snapshot) {
            hud.hidden = YES;
            if ([snapshot exists]) {
                
                arr_everyTransactionsForBank = [[NSArray alloc] initWithArray: snapshot.value];
                [tableViewOfTransactions reloadData];
                
                tableViewOfTransactions.hidden = NO;
                [btn_addMoreBank setTitle: @"BACK" forState: UIControlStateNormal];
                
            }
        }];
        
    }
}

#pragma mark UIWebView Usage for Plaid API integration

/////////// UIWebView
// Helper method to generate the Link initialization URL given a dictionary of Link initialization keys and values
// The Webview should be loaded wtuh the URL returned by this function.
-(NSURL*)generateLinkInitializationURLWithOptions:(NSDictionary*)options {
    // http://stackoverflow.com/questions/718429/creating-url-query-parameters-from-nsdictionary-objects-in-objectivec
    NSURLComponents *components = [NSURLComponents componentsWithString:[options objectForKey:@"baseUrl"]];
    NSMutableArray *queryItems = [NSMutableArray array];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"isWebview" value:@"true"]];
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"isMobile" value:@"true"]];
    for (NSString *key in options) {
        if (![key isEqualToString:@"baseUrl"]) {
            [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:options[key]]];
        }
    }
    components.queryItems = queryItems;
    return [components URL];
};

// Helper method to generate a dictionary based on a Plaid Link action URL
-(NSMutableDictionary*)dictionaryFromLinkUrl:(NSURL*)linkURL {
    NSURLComponents *components = [NSURLComponents componentsWithString:linkURL.absoluteString];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    for(NSURLQueryItem *item in components.queryItems) {
        if ([item.name isEqualToString: @"public_token"] || [item.name isEqualToString: @"institution_name"]
            || [item.name isEqualToString: @"institution_id"]) {
            [dict setObject:item.value forKey:item.name];
        }
        
    }
    return dict;
}

#pragma mark - UIWebViewDelegate methods

// This delegate method is used to grab any links used to "talk back" to Objective-C code from the html/JavaScript
-(BOOL) webView:(UIWebView *)inWeb
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)type {
    
    // Handle actions dispatched on the Link scheme, "plaidlink"
    // The host dictates the action type (such as "connected" or "exit") and
    // the querystring includes data such as the public_token and institution metadata.
    NSString *linkScheme = @"plaidlink";
    NSString *actionScheme = request.URL.scheme;
    NSString *actionType = request.URL.host;
    
    if ([actionScheme isEqualToString:linkScheme]) {
        NSLog(@"PLaid Link detected: %@", request.URL.absoluteString);
        if ([actionType isEqualToString:@"connected"]) {
            // Close the UIWebView
            _webview.hidden = YES;
            
            // Parse data passed from Link into a dictionary
            // This includes the public_token as well as account and institution metadata
            
            NSDictionary* linkData = [self dictionaryFromLinkUrl:request.URL];
            // Output data from Link
            NSLog(@"Public Token: %@", [linkData objectForKey:@"public_token"]);
//            NSLog(@"Account ID: %@", [linkData objectForKey:@"account_id"]);
            NSLog(@"Institution id: %@", [linkData objectForKey:@"institution_id"]);
            NSLog(@"Institution name: %@", [linkData objectForKey:@"institution_name"]);
            
            [self showProgressBar: @"Exchanging access token..."];
            
            [self exchangeAccessToken: linkData];
            
            
        } else if ([actionType isEqualToString:@"exit"]) {
            // Close the UIWebView
            _webview.hidden = YES;
            
            // Parse data passed from Link into a dictionary
            // This includes information about where the user was in the Link flow,
            // any errors that occurred, and request IDs
            NSLog(@"URL: %@", request.URL.absoluteString);
            NSDictionary* linkData = [self dictionaryFromLinkUrl:request.URL];
            // Output data from Link
            NSLog(@"User status in flow: %@", [linkData objectForKey:@"status"]);
            // The requet ID keys may or may not exist depending on when the user exited
            // the Link flow.
            NSLog(@"Link request ID: %@", [linkData objectForKey:@"link_request_id"]);
            NSLog(@"Plaid API request ID: %@", [linkData objectForKey:@"plaid_api_request_id"]);
        } else {
            NSLog(@"Link action detected: %@", actionType);
//            [self presentAlertViewWithTitle:@"Exit" message: [NSString stringWithFormat: @"Link action detected: %@", actionType]];
        }
        // Do not load these requests
        return NO;
    } else if (UIWebViewNavigationTypeLinkClicked == type &&
               ([actionScheme isEqualToString:@"http"] ||
                [actionScheme isEqualToString:@"https"])) {
                   // Handle http:// and https:// links inside of Plaid Link,
                   // and open them in a new Safari page. This is necessary for links
                   // such as "forgot-password" and "locked-account"
                   [[UIApplication sharedApplication] openURL:[request URL]];
                   return NO;
               } else {
                   NSLog(@"Unrecognized URL scheme detected that is neither HTTP, HTTPS, or related to Plaid Link: %@", request.URL.absoluteString);
//                   [self presentAlertViewWithTitle:@"Exit" message: [NSString stringWithFormat: @"Unrecognized URL scheme detected that is neither HTTP, HTTPS, or related to Plaid Link: %@", request.URL.absoluteString]];
                   return YES;
               }
}

- (void) showProgressBar: (NSString *) message
{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = message;
}

- (void) exchangeAccessToken: (NSDictionary *) metadata
{
    NSString *publicToken = [metadata objectForKey:@"public_token"];
    NSString *institution_name = [metadata objectForKey: @"institution_name"];
    NSString *institution_id = [metadata objectForKey: @"institution_id"];
    
    [httpClientPlaid getAccessTokenWithCompletionHandler:publicToken withCompletionHandler:^(NSInteger responseCode, NSDictionary *responseObj) {
        hud.hidden = YES;
        if (responseCode == 200) {
            NSLog(@"%@", responseObj);
            NSString *access_token = [responseObj objectForKey: @"access_token"];
//            NSString *requestID = [responseObj objectForKey: @"request_id"];
//            NSString *item_id = [responseObj objectForKey: @"item_id"];
            
            // store access_token with institution_name
            saveDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     access_token, @"access_token",
                                     institution_name, @"institution_name",
                                     institution_id, @"institution_id", nil];
            
            [self showProgressBar: @"Storing access token..."];
            
            [[dbRef child: [saveDic objectForKey: @"institution_name"]]
             setValue: saveDic withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                 
                 hud.hidden = YES;
                 
                 if (error) {
                     [self showMessagePrompt: [NSString stringWithFormat: @"storing accesstoken error: %@", error.localizedDescription]];
                 } else
                 {
                     // download transactions for current bank and save on firebase for a month
                     
//                     [self showMessagePrompt: @"Please select the cell to show transactions"];
                     
                     [self showProgressBar: @"Collecting transactions..."];
                     
                     [self calcDate];
                     
                     // store db
                     [self downloadTransactionsAndStoreOnFirebase: saveDic startDate: lastMonthStartDate endDate: currentEndDate isCurrentMonth: 1];
                     
                 }
             }];
            
        } else
        {
            [self showMessagePrompt: @"Something went wrong while exchange public token for access token"];
        }
        
    }];
}

- (void) calcDate
{
    // for this month
    
    currentYear = [self getDateTime:0 format: @"y"];
    currentMonth = [self getDateTime:0 format: @"m"];
    currentStartDate = [NSString stringWithFormat: @"%@-%@-01", currentYear, currentMonth];
    currentEndDate = [self getDateTime: 0 format: nil];
    
    // for last month
    int temp;
    
    if ([currentMonth isEqualToString: @"01"]) {
        temp = [currentYear intValue] - 1;
        lastYear = [NSString stringWithFormat: @"%d", temp];
        
        lastMonth = @"12";
        
    } else
    {
        lastYear = currentYear;
        
        temp = [currentMonth intValue] - 1;
        if (temp < 10) {
            lastMonth = [NSString stringWithFormat: @"0%d", temp];
        } else
            lastMonth = [NSString stringWithFormat: @"%d", temp];
        
    }
    lastMonthStartDate = [NSString stringWithFormat: @"%@-%@-01", lastYear, lastMonth];
    lastMonthEndDate = [NSString stringWithFormat: @"%@-%@-31", lastYear, lastMonth];
}
- (void) downloadTransactionsAndStoreOnFirebase: (NSDictionary *) metadata startDate: (NSString *) mStartDate endDate: (NSString *) mEndDate isCurrentMonth: (int) isNowMonth
{

    NSString *accessToken = [metadata objectForKey: @"access_token"];
//    NSString *startDate = [self getDateTime: pastDate];
//    NSString *endDate = [self getDateTime: 0];
    
//    NSLog(@"----------%@,%@,%@", accessToken, startDate, endDate);
    
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, TRANS_DELAY * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        
        [httpClientPlaid downloadTransactionsForAccessToken: accessToken
                                                   fromDate: mStartDate
                                                     toDate: mEndDate
                                      withCompletionHandler:^(NSInteger responseCode, NSArray *transactions) {
                                          hud.hidden = YES;
                                          if (responseCode == 200) {
                                              if (transactions != nil) {
                                                  
                                                  NSMutableArray *currentMonthTransactions = [[NSMutableArray alloc] init];
                                                  NSMutableArray *lastMonthTransactions = [[NSMutableArray alloc] init];
                                                  for (int i=0; i<transactions.count; i++) {
                                                      NSDictionary *dic = [transactions objectAtIndex: i];
                                                      NSString *mDateString = [dic objectForKey: @"date"];
                                                      NSString *indexMonth = [[mDateString substringFromIndex:5] substringToIndex: 2];
                                                      if ([currentMonth isEqualToString: indexMonth]) {
                                                          [currentMonthTransactions addObject: dic];
                                                      } else if ([lastMonth isEqualToString: indexMonth])
                                                      {
                                                          [lastMonthTransactions addObject: dic];
                                                      }
                                                  }
                                                  [[[dbRef child: [metadata objectForKey: @"institution_name"]] child: @"transactions"]
                                                   setValue:currentMonthTransactions];
                                                  
                                                  [[[dbRef child: [metadata objectForKey: @"institution_name"]] child: @"last_month_transactions"]
                                                   setValue:lastMonthTransactions];
                                                  
                                                  [self downloadAccountDetails: metadata];
                                              }
                                          } else
                                          {
                                              [self showMessagePrompt:  @"Something went wrong while download transactions"];
                                          }
                                          
                                      }];
    });
    
    
}

- (void) downloadAccountDetails: (NSDictionary *) metadata {
    
    NSString *accessToken = [metadata objectForKey: @"access_token"];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, TRANS_DELAY * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [httpClientPlaid downloadAccountDetailsForAccessToken: accessToken
                                        withCompletionHandler:^(NSInteger responseCode, NSArray *accountDetails) {
                                            if (responseCode == 200) {
                                                if (accountDetails != nil) {
                                                    [[[dbRef child: [metadata objectForKey: @"institution_name"]] child: @"accounts"]
                                                     setValue:accountDetails];
                                                }
                                            }
                                        }];
    });
        
    
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

- (void)webViewDidStartLoad:(UIWebView *)webView {
    // handle webViewDidStartLoad
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // handle webViewDidFinishLoad
}

@end
