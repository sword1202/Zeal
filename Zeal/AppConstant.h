//
//  AppConstant.h
//  Zeal
//
//  Created by P1 on 12/27/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#ifndef AppConstant_h
#define AppConstant_h

//
#define TEST_MODE    0
#define UID @"pSc6HtBiftTDEMO9pZS703t5Ilf2"
#define KEY(str)    [CommonUtils getString:str]
//#define TEST_ACCESS_TOKEN @"access-development-a26e7388-b04f-43a9-aceb-842882d2f4a7" // BANK OF AMERICA
#define TEST_ACCESS_TOKEN @"access-development-29f1bca3-2886-4097-8aff-7c7e966c9777" // American Express
// Key For Plaid API Integration
#define PLAID_PUBLIC_KEY @"667778757a11bac2a6ee9b156c914a"
// production, development, sandbox
#define ENV @"development"
//#define ENV @"sandbox"
#define CLIENT_NAME @"ZEAL"
#define PRODUCTION @"transactions" // auth, transactions, balance, identity, income
#define TRANS_DELAY 12.0
#define ACCESSTOKEN_SQUAREUP @"sq0atp-wXX9R-mHWTTSQtcLhwKQbw"
#define kAccount @"accounts"
#define kmonthly @"monthly_transaction"

// coffeelist db
#define kcoffeelist @"coffee_list"
#define kcategoryName @"title_name"
#define klocationID @"location_id"
#define kImageName  @"img_name"
#define kOrderLists @"orderlists"

/*
 username: user_good
 password: pass_good
 pin: credential_good (when required)
 */

//sandbox (tartan, development, production)
#define kPlaidBaseURL [NSString stringWithFormat: @"https://%@.plaid.com", ENV]
#define kSquareupBaseURL @"https://connect.squareup.com"

#endif /* AppConstant_h */
