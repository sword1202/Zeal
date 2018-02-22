//
//  AppDelegate.h
//  Zeal
//
//  Created by P1 on 5/22/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) BOOL feedbackAddButtonAndBackButtonFlag;
@property (nonatomic, assign) BOOL onceInitFlag;
@property (nonatomic, assign) int indexOfSelectedImageOfMerchantAccount;
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSArray *arr_pharmacy_merchantAccounts;
@property (nonatomic, strong) NSArray *arr_home_merchantAccounts;
@property (nonatomic, assign) int indexOfSelectedMenu;
@property (nonatomic, retain) NSString *mUserName;
@property (nonatomic, retain) NSString *mUserID;
@property (nonatomic, retain) NSString *mUserEmail;
@property (nonatomic, retain) UIImage *mFBProfile;
@property (nonatomic, assign) BOOL isSelectedPlusButtonForHome;
// optional
@property (nonatomic, assign) BOOL showChatFlag;
@property (nonatomic, assign) long maxAmount;
- (void) addMFSideMenu;
@end

