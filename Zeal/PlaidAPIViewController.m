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
#import "TransactionsCellTableViewCell.h"
#import "ReorderTableCell.h"
#import "PlaidHTTPClient.h"
#import "UIViewController+Alerts.h"
#import "MBProgressHUD.h"
@import Firebase;

@interface PlaidAPIViewController ()
{
    __weak IBOutlet UIButton *btn_linkWithPlaid;
    __weak IBOutlet UIButton *btn_addMoreBank;
    __weak IBOutlet UIView *tableViewContainer;
    NSMutableArray *arr_savedFinancialAccounts, *arrOfficialNames, *arrAmounts, *arrBanks;
    NSArray *arr_everyTransactionsForBank;
    FIRDatabaseReference *dbRef;
    PlaidHTTPClient *httpClientPlaid;
    // params of Cell
    NSDictionary *saveDic, *institutionsDic;
    NSInteger selectedReorderIndex;
    MBProgressHUD *hud;
    NSString *sel_institution_id;
    NSString *lastMonthStartDate,* lastMonthEndDate,
            *currentYear, *currentMonth, *currentStartDate, *currentEndDate;
    BOOL isUpdate;
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
    _webview.hidden = YES;

    [table_view registerNib: [UINib nibWithNibName: @"CustomTableFinancialAccountsTableViewCell" bundle:nil] forCellReuseIdentifier: @"cell_financial"];

    [tableViewOfTransactions registerNib: [UINib nibWithNibName: @"TransactionsCellTableViewCell" bundle:nil] forCellReuseIdentifier: @"cell_financial"];

[_reorderTableView registerNib: [UINib nibWithNibName: @"ReorderTableCell" bundle:nil] forCellReuseIdentifier: @"reorder"];
    
    // initialize PlaidClientHttp to retrieve transactions
    httpClientPlaid = [PlaidHTTPClient sharedPlaidHTTPClient];
    
    [self getListsOfInstitutions];
    isUpdate = NO;
    [self retreiveDataFromDB];
    [self createBaseLineOfButton];
    [self setReorderView];
    
}

- (void) setReorderView {
    _sendReorderBtn.clipsToBounds = YES;

    //half of the width
    _sendReorderBtn.layer.cornerRadius = 10;
    _sendReorderBtn.layer.borderColor=[UIColor blueColor].CGColor;
    _sendReorderBtn.layer.borderWidth=2.0f;
    selectedReorderIndex = 0;
    
}
- (void) getListsOfInstitutions
{
//    [httpClientPlaid downloadPlaidInstitutionsWithCompletionHandler:^(NSArray *institutions) {
//        NSLog(@"...");
//    }];
    institutionsDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @"amex",       @"ins_10",
                       @"bbt",        @"ins_2",
                       @"bbvac",      @"ins_23",
                       @"bofa",       @"ins_1",
                       @"capone",     @"ins_9",
                       @"chase",      @"ins_3",
                       @"citizens",   @"ins_20",
                       @"citi",       @"ins_5",
                       @"huntington", @"ins_21",
                       @"keybank",    @"ins_29",
                       @"mtb",        @"ins_27",
                       @"nfcu",       @"ins_15",
                       @"pnc",        @"ins_13",
                       @"regions",    @"ins_19",
                       @"schwab",     @"ins_11",
                       @"simple",     @"ins_24",
                       @"suntrust",   @"ins_16",
                       @"td",         @"ins_14",
                       @"us",         @"ins_6",
                       @"usaa",       @"ins_7",
                       @"wells",      @"ins_4", nil];
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
    arrAmounts = [[NSMutableArray alloc] init];
    arrOfficialNames = [[NSMutableArray alloc] init];
    arrBanks = [[NSMutableArray alloc] init];
    NSString *userID = TEST_MODE==1 ? UID:[[[FIRAuth auth] currentUser] uid];
    dbRef = [[[baseDBRef child:kconsumers] child: userID] child: kFINANCIAL_DB];
    if (dbRef != nil) {
        
        [self showProgressBar: @"Loading..."];
        
        [dbRef observeEventType:(FIRDataEventTypeValue) withBlock: ^(FIRDataSnapshot *_Nonnull snapshot) {
            if ([snapshot exists]) {
                arr_savedFinancialAccounts = [[NSMutableArray alloc] init];
                
                arrOfficialNames = [[NSMutableArray alloc] init];
                arrAmounts = [[NSMutableArray alloc] init];
                arrBanks = [[NSMutableArray alloc] init];

                
                NSMutableArray *bankNames = [[NSMutableArray alloc] init];
                for (snapshot in snapshot.children) {
                    [bankNames addObject: snapshot.key];
                    [arr_savedFinancialAccounts addObject:[snapshot value]];
                }
                
                NSMutableArray *cardNumbersArray = [NSMutableArray new];
                
                for (int i=0; i<arr_savedFinancialAccounts.count; i++) {
                    NSDictionary *eachBank = [arr_savedFinancialAccounts objectAtIndex: i];
                    
                    // download transaction every month first day automatically
                    if ([eachBank objectForKey: kAccessToken] == nil) {
                        [[dbRef child: [bankNames objectAtIndex: i]] setValue: nil];
                        continue;
                    }
                    saveDic = [NSDictionary dictionaryWithObjectsAndKeys:
                               [eachBank objectForKey: kAccessToken], kAccessToken,
                               [eachBank objectForKey: kInstitutionName], kInstitutionName,
                               [eachBank objectForKey: kInstitutionID], kInstitutionID, nil];
                    
                    [self calcDate];
                    
                    // store db
                    [self downloadTransactionsAndStoreOnFirebase: saveDic startDate: lastMonthStartDate endDate: currentEndDate isCurrentMonth: 1];
                    
                    // update card numbers
                    
                    
                    NSArray *accounts = [eachBank objectForKey: kAccount];
                    for (int j = 0; j < accounts.count; j ++) {
                        NSDictionary *eachAccountsinBank = [accounts objectAtIndex: j];
                        NSString *cardNo = [eachAccountsinBank objectForKey: @"mask"];
                        [cardNumbersArray addObject: cardNo];
                        for (int k = 0; k < cardNumbersArray.count-1; k++) {
                            if ([cardNo isEqualToString:[cardNumbersArray objectAtIndex: k]]) {
                                [cardNumbersArray removeObjectAtIndex:cardNumbersArray.count-1];
                                break;
                            }
                        }
                        
                        
                    }
                    
                    ///
                    
                    if ([eachBank objectForKey: @"monthly_transaction"] != nil && [[eachBank objectForKey: @"monthly_transaction"] objectForKey: [CommonUtils getMonthKey: currentMonth]] != nil) {
                        NSArray *currentMonthTransactions = [[eachBank objectForKey: @"monthly_transaction"] objectForKey: [CommonUtils getMonthKey: currentMonth]];
                        
                        for (int j=0 ; j < currentMonthTransactions.count; j++) {
                            NSDictionary *eachTransaction = [currentMonthTransactions objectAtIndex: j];
                            [arrAmounts addObject: [eachTransaction objectForKey: @"amount"]];
                            [arrBanks addObject: [bankNames objectAtIndex: i]];
                            [arrOfficialNames addObject: [eachTransaction objectForKey: @"name"]];
                        }
                    }
                                            
                                           

                                            
                                            
                }
                    
                
                [[[[baseDBRef child:kconsumers] child: userID] child: klinked_cards] setValue: cardNumbersArray];
 
                tableViewContainer.hidden = NO;
                [table_view reloadData];
                [tableViewOfTransactions reloadData];
                // reload transaction view
                
//                [self retrievTransactions:@"ins_1"];
            } else
            {
                hud.hidden = YES;
                tableViewContainer.hidden = YES;
            }
        }];
        
    } else
    {
        hud.hidden = YES;
        tableViewContainer.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didConnectPlaidLink:(id)sender {
    
    if ([btn_addMoreBank.titleLabel.text isEqualToString: @"BACK"]) {
        [btn_addMoreBank setTitle: @"Add Bank" forState: UIControlStateNormal];
    } else
    {
        [self initWebViewForPlaid];
        isUpdate = NO;
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
        tableCellCount = arrAmounts.count;
    } else if (tableView.tag == 300 && arrAmounts.count >0) {
        tableCellCount = 1;
    }
    return tableCellCount;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id returnValue = nil;
    if (tableView.tag == 100) {
        CustomTableFinancialAccountsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell_financial" forIndexPath:indexPath];
        NSDictionary *dic = [arr_savedFinancialAccounts objectAtIndex: indexPath.row];
        cell.plaid_main_list_view.hidden = NO;
        cell.plaid_title.text = @"Plaid";
        cell.plaid_subTitle.text = [dic objectForKey: @"institution_name"];
        cell.logo_img_ChartView.hidden = YES;
        NSString *institutionName = [institutionsDic objectForKey: [dic objectForKey: @"institution_id"]];
        
        UIImage *image = [UIImage imageNamed: institutionName];
        //display general image
//        UIImage *image = [UIImage imageNamed: @"plaid_logo"];
        if (image != nil) {
            cell.plaid_institution_logo.image = image;
        }
        
        cell.btn_close.hidden = NO;
        cell.btn_close.tag = indexPath.row;
        
        [cell.btn_close addTarget:self action:@selector(didSelectClose:) forControlEvents:UIControlEventTouchUpInside];
        
        returnValue = cell;
    } else if (tableView.tag == 200)
    {
        TransactionsCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell_financial" forIndexPath:indexPath];
        
        NSString *institutionName = [institutionsDic objectForKey: sel_institution_id];
        
        NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
        [fmt setPositiveFormat:@"0.##"];
        NSLog(@"%@", [fmt stringFromNumber:[NSNumber numberWithFloat:25.342]]);
        float amount = [[arrAmounts objectAtIndex: indexPath.row] floatValue];
        if (amount < 0) {
            amount = 0 - amount;
            cell.amount_label.text = [NSString stringWithFormat: @"$ -%.2f", amount];
//            cell.mAmounts.textColor = [UIColor redColor];
        } else
        {
            cell.amount_label.text = [NSString stringWithFormat: @"$ %.2f", amount];
//            cell.mAmounts.textColor = [UIColor blackColor];
        }
        
        cell.btn_reorder.clipsToBounds = YES;

        //half of the width
        cell.btn_reorder.layer.cornerRadius = 10;
        cell.btn_reorder.layer.borderColor=[UIColor blueColor].CGColor;
        cell.btn_reorder.layer.borderWidth=2.0f;
        
        cell.officialname_label.text = [arrOfficialNames objectAtIndex: indexPath.row];
        cell.btn_reorder.tag = indexPath.row;
        
        [cell.btn_reorder addTarget:self action:@selector(didSelectReorder:) forControlEvents:UIControlEventTouchUpInside];
        
        returnValue = cell;
        
    } else {
        ReorderTableCell *cell = [tableView dequeueReusableCellWithIdentifier: @"reorder" forIndexPath:indexPath];
        cell.orderName.text = [arrOfficialNames objectAtIndex: selectedReorderIndex];
        long amount = [[arrAmounts objectAtIndex: selectedReorderIndex] longValue];
                if (amount < 0) {
                    amount = 0 - amount;
                    cell.orderAmount.text = [NSString stringWithFormat: @"$ -%lu", amount];
        //            cell.mAmounts.textColor = [UIColor redColor];
                } else
                {
                    cell.orderAmount.text = [NSString stringWithFormat: @"$ %lu", amount];
        //            cell.mAmounts.textColor = [UIColor blackColor];
                }
        returnValue = cell;
    }
    
    return returnValue;
}

-(void)didSelectReorder:(UIButton*)sender
{
    self.bodyView.hidden = YES;
    self.reorderView.hidden = NO;
    _reorderOfficialNameLabel.text = [arrOfficialNames objectAtIndex: sender.tag];
    selectedReorderIndex = sender.tag;
    
    long amount = [[arrAmounts objectAtIndex: selectedReorderIndex] longValue];
            if (amount < 0) {
                amount = 0 - amount;
                _reorderAmountLabel.text = [NSString stringWithFormat: @"$ -%lu", amount];
    //            cell.mAmounts.textColor = [UIColor redColor];
            } else
            {
                _reorderAmountLabel.text = [NSString stringWithFormat: @"$ %lu", amount];
    //            cell.mAmounts.textColor = [UIColor blackColor];
            }
    
    [_reorderTableView reloadData];
}

-(void)didSelectClose:(UIButton*)sender
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Zeal"
                                 message:@"Are You Sure Want to Delete?"
                                 preferredStyle:UIAlertControllerStyleAlert];

    //Add Buttons

    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    [self clearAllData: sender];
                                }];

    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];

    //Add your buttons to alert controller

    [alert addAction:yesButton];
    [alert addAction:noButton];

    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void) clearAllData: (UIButton *) sender {
    NSDictionary *dic = [arr_savedFinancialAccounts objectAtIndex: sender.tag];
    NSString *institutionName = [dic objectForKey: @"institution_name"];
    
    [[dbRef child: institutionName] setValue: nil];
}

- (IBAction)didSelectSendOrder:(UIButton *)sender {
    self.bodyView.hidden = NO;
    self.reorderView.hidden = YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog( @"%d --- '%d'", (int)indexPath.row, (int)tableView.tag);
    
    
    // test monthly transaction on the first of the month
//    [self calcDate];
//
//    // store db
//    [self downloadTransactionsAndStoreOnFirebase: saveDic startDate: lastMonthStartDate endDate: currentEndDate isCurrentMonth: 1];
    
    // Test Account Details
//    [httpClientPlaid downloadAccountDetailsForAccessToken: TEST_ACCESS_TOKEN
//                                    withCompletionHandler:^(NSInteger responseCode, NSArray *accountDetails) {
//                                        if (responseCode == 200) {
//                                            if (accountDetails != nil) {
//                                                NSLog(accountDetails);
//                                            }
//                                        }
//                                    }];
    // ************** //
    
    [tableView deselectRowAtIndexPath: indexPath animated:NO];

//    if (tableView.tag == 100) {
//        NSDictionary *sel_dic = [arr_savedFinancialAccounts objectAtIndex: indexPath.row];
//        sel_institution_id = [sel_dic objectForKey: @"institution_id"];
//        [self retrievTransactions: [sel_dic objectForKey: @"institution_name"]];
//
//    }
    
}

- (void) retrievTransactions: (NSString *) institutionName
{
    if ([[dbRef child: institutionName] child: @"transactions"] != nil) {
        
        [self showProgressBar: @"Loading..."];
        [[[dbRef child: institutionName] child: @"accounts"] observeSingleEventOfType:(FIRDataEventTypeValue) withBlock: ^(FIRDataSnapshot *_Nonnull snapshot) {
            hud.hidden = YES;
            if ([snapshot exists]) {
                
                arr_everyTransactionsForBank = [[NSArray alloc] initWithArray: snapshot.value];
                [tableViewOfTransactions reloadData];
                
                tableViewOfTransactions.hidden = NO;
//                [btn_addMoreBank setTitle: @"BACK" forState: UIControlStateNormal];
                
            }
        }];
        
    }
}

#pragma mark UIWebView Usage for Plaid API integration

/////////// UIWebView
// Helper method to generate the Link initialization URL given a dictionary of Link initialization keys and values
// The Webview should be loaded wtuh the URL returned by this function.
-(NSURL*)generateLinkInitializationURLWithOptions:(NSDictionary*)options {

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
            NSString *access_token = [responseObj objectForKey: kAccessToken];
//            NSString *requestID = [responseObj objectForKey: @"request_id"];
//            NSString *item_id = [responseObj objectForKey: @"item_id"];
            
            // store access_token with institution_name
            saveDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     access_token, kAccessToken,
                                     institution_name, kInstitutionName,
                                     institution_id, kInstitutionID, nil];
            
            [self showProgressBar: @"Storing access token..."];
            
            [[dbRef child: [saveDic objectForKey: kInstitutionName]]
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
//    int temp;
    
    if ([currentMonth isEqualToString: @"01"]) {
//        temp = [currentYear intValue] - 1;
//        lastYear = [NSString stringWithFormat: @"%d", temp];
//
//        lastMonth = @"12";
        
    } else
    {
        
//        temp = [currentMonth intValue] - 1;
//        if (temp < 10) {
//            lastMonth = [NSString stringWithFormat: @"0%d", temp];
//        } else
//            lastMonth = [NSString stringWithFormat: @"%d", temp];
    }
    lastMonthStartDate = [NSString stringWithFormat: @"%@-01-01", currentYear];
    lastMonthEndDate = [NSString stringWithFormat: @"%@-01-31", currentYear];
}

- (void) downloadTransactionsAndStoreOnFirebase: (NSDictionary *) metadata startDate: (NSString *) mStartDate endDate: (NSString *) mEndDate isCurrentMonth: (int) isNowMonth
{

    NSString *accessToken = [metadata objectForKey: kAccessToken];
    
    if (isUpdate || accessToken == nil) {
        isUpdate = NO;
        return;
    }
    
    isUpdate = YES;
    
    
//    accessToken = @"access-development-a26e7388-b04f-43a9-aceb-842882d2f4a7";
//    NSString *startDate = [self getDateTime: pastDate];
//    NSString *endDate = [self getDateTime: 0];
    
    NSLog(@"----------%@,%@,%@", accessToken, mStartDate, mEndDate);
    
    
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
                                                  
//                                                  NSMutableArray *currentMonthTransactions = [[NSMutableArray alloc] init];
//                                                  NSMutableArray *lastMonthTransactions = [[NSMutableArray alloc] init];
                                                  NSMutableDictionary *monthlyTransactions = [[NSMutableDictionary alloc] init];
                                                  NSString *oldMonthKey = @"";
                                                  NSMutableArray *oldMonthlyTransaction = [[NSMutableArray alloc] init];
                                                  for (int i=0; i<transactions.count; i++) {
                                                      NSDictionary *dic = [transactions objectAtIndex: i];
                                                      NSString *mDateString = [dic objectForKey: @"date"];
                                                      NSString *indexMonth = [[mDateString substringFromIndex:5] substringToIndex: 2];
                                                      NSString *monthKey = [CommonUtils getMonthKey: indexMonth];
                                                      if ([oldMonthKey isEqualToString: @""]) {
                                                          oldMonthKey = monthKey;
                                                      } else if (![oldMonthKey isEqualToString: monthKey])
                                                      {
                                                          oldMonthKey = monthKey;
                                                          [oldMonthlyTransaction removeAllObjects];
                                                      } else if (i == transactions.count - 1)
                                                      {
                                                          
                                                      }
                                                      
                                                      [oldMonthlyTransaction addObject: dic];
                                                      monthlyTransactions[oldMonthKey] = [oldMonthlyTransaction copy];
                                                  }
                                                  
                                                  [[[dbRef child: [metadata objectForKey: @"institution_name"]] child: kmonthly] setValue: monthlyTransactions];
                                                  
                                                  [self downloadAccountDetails: metadata];
                                              }
                                          } else
                                          {
                                              [self showMessagePrompt:  @"Something went wrong while download transactions"];
                                          }
                                          
                                      }];
    });
    
    
}

-(NSDictionary *)groupByKey:(NSString *) key array: (NSArray *)objectArray{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    for (id obj in objectArray) {
        id keyValue = [obj valueForKey:key];
        NSMutableArray *arr = dictionary[keyValue];
        if (! arr) {
            arr = [NSMutableArray array];
            dictionary[keyValue] = arr;
        }
        [arr addObject:obj];
    }
    return [dictionary copy];
}

- (void) downloadAccountDetails: (NSDictionary *) metadata {
    
    NSString *accessToken = [metadata objectForKey: kAccessToken];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, TRANS_DELAY * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [httpClientPlaid downloadAccountDetailsForAccessToken: accessToken
                                        withCompletionHandler:^(NSInteger responseCode, NSArray *accountDetails) {
                                            if (responseCode == 200) {
                                                if (accountDetails != nil) {
                                                    
                                                    [[[dbRef child: [metadata objectForKey: kInstitutionName]] child: kAccount]
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
