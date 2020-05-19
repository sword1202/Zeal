//
//  AppDelegate.m
//  Zeal
//
//  Created by P1 on 5/22/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import "AppDelegate.h"
@import Firebase;
@import GoogleSignIn;
#import "MFSideMenuContainerViewController.h"
//#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize feedbackAddButtonAndBackButtonFlag, indexOfSelectedImageOfMerchantAccount, onceInitFlag, menuItems, indexOfSelectedMenu, mUserID, mUserName, mUserEmail, mFBProfile, showChatFlag, arr_shops_merchantAccounts, maxAmount,arr_eating_merchantAccounts, arr_travel_merchantAccounts, isSelectedPlusButtonForHome, arrForLineGraphDataLastMonth, arrForLineGraphDataCurrentMonth, isMaxInLast, arrMerchantShops, arrMerchantEatings;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"ENVVVVV-----------");
    NSLog(ENV);
    //    #if USE_CUSTOM_CONFIG
    //        [self setupPlaidLinkWithCustomConfiguration];
    //    #else
    //        [self setupPlaidLinkWithSharedConfiguration];
    //    #endif
//    [self setupPlaidLinkWithSharedConfiguration];
    
    // initialize variables;
    [[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [[UINavigationBar appearance] setBackgroundImage: [UIImage imageNamed: @"header_background"] forBarMetrics: UIBarMetricsDefault];
    [[UINavigationBar appearance] setTranslucent: NO];
    
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
//
//    [[self.navigationController navigationBar] setBackgroundImage: [UIImage imageNamed: @"header_background"] forBarMetrics: UIBarMetricsDefault];
//
//    [self.navigationController.navigationBar setTranslucent: NO];
//    [[UINavigationBar appearance] setShadowImage: [[UIImage alloc] init]];
//    [self.navigationController.navigationBar setValue:@(YES) forKeyPath:@"hidesShadow"];
    
    [self initializeOfVar];
    
    [self addMFSideMenu];
    
    // Home Items
    
    arr_eating_merchantAccounts = [[NSArray alloc] initWithObjects:
                                 [[NSDictionary alloc] initWithObjectsAndKeys: @"best_buy", @"img_name", @"Best Buy", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category",@"http://www-ssl.bestbuy.com/identity/signin?token=tid%3A97dc4efa-18be-11e7-a26d-005056920f07", @"link", nil],
                                 [[NSDictionary alloc] initWithObjectsAndKeys: @"jc_penney", @"img_name", @"JC Penny", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"https://www.jcprewards.com/", @"link", nil],
                                 
                                 [[NSDictionary alloc] initWithObjectsAndKeys: @"rei", @"img_name", @"REI", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.jcprewards.com/", @"link", nil],
                                 [[NSDictionary alloc] initWithObjectsAndKeys: @"fred_meyer", @"img_name", @"Fred Meyer", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.fredmeyer.com/account/create", @"link", nil],
                                 [[NSDictionary alloc] initWithObjectsAndKeys: @"qfc", @"img_name", @"QFC", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.qfc.com/account/create", @"link", nil],
                                 [[NSDictionary alloc] initWithObjectsAndKeys: @"safe_way", @"img_name", @"Safeway", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.safeway.com/CMS/account/register/?bannerId=safeway&FullSite=Y&goto=http:%2F%2Fwww.safeway.com%2FShopStores%2FOffers-Landing-IMG.page%3Fcmpid%3Dco_kw_700000001291346_71700000013870022_58700001116047740_p10059066649%26gclid%3DCj0KEQjw5YfHBRDzjNnioYq3_swBEiQArj4pdL7HVMRLfqEMlJEJAoNqTQ2TjZDNloWGlIe08ve1OlkaAkCp8P8HAQ%26dclid%3DCOLKg5OvidMCFU93YgodseEE2w", @"link", nil],
                                 [[NSDictionary alloc] initWithObjectsAndKeys: @"ikea", @"img_name", @"Ikea", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://secure.ikea.com/webapp/wcs/stores/servlet/LogonForm?langId=-1&storeId=12&krypto=sNKhj2OZZ3reHy29UD646MsGt4eouJFP8etAz75yEZD7eGSf96cZ9SUOGmE1t%2B8bwabmMXuP2IzrP6CUKM2HyBLj22T9g9rx7KTrzeOBgEeD1mp447Bz69DTe8v9IoR8oBmGSurf5VYbZ05RpYGDIre3JKNVnTPMW7dR0qsX6KkbVvu8QOgVKzMPefspez4krFbIkSGvOtkat2kSxuC3Xgx%2BjKLNYaNQ67zr9secJoc%3D&ddkey=https%3AUpdateUser", @"link", nil],
                                 [[NSDictionary alloc] initWithObjectsAndKeys: @"pet_smart", @"img_name", @"Petsmart", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.petsmart.ca/account/", @"link", nil],
                                 [[NSDictionary alloc] initWithObjectsAndKeys: @"lowes", @"img_name", @"Lowe's", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.lowes.com/webapp/wcs/stores/servlet/UserRegistrationForm?storeId=10151&catalogId=10051&langId=-1&krypto=EJ2KE8BMfJumd8Uo7SMFi5S6sAXbnRxpIvsZirMfG4jgGEePe0BUQCI3jEAq%2BZDo7BfpXH3JU42WmZk4xhTkWr6U1CgIY7HurxCCu6tCDeWd6k3JKxk%2Bgzb5s8IOZCm%2Fhui9%2FOMopcC%2FxQHpDfbYDw%3D%3D", @"link", nil],
                                 [[NSDictionary alloc] initWithObjectsAndKeys: @"office_depot", @"img_name", @"Office Depot", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.officedepot.com/account/registrationDisplay.do", @"link", nil],
                                 [[NSDictionary alloc] initWithObjectsAndKeys: @"staples", @"img_name", @"Staples", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.staples.com/office/supplies/StaplesManageRegistration?catalogId=10051&langId=-1&storeId=10001&krypto=9YxXH2e6712%2B9tefHjLFu7ym8Wxl0IvJv2qHNorUZCYpKkBhZuw4a3pU6xK7M27NqMgxVgv8RbKAQM1NxaIZyA%3D%3D&ddkey=http%3AStaplesManageRegistration", @"link", nil],
                                 [[NSDictionary alloc] initWithObjectsAndKeys: @"thebodyshop", @"img_name", @"The Body Shop", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.thebodyshop.com/en-us/login?loginAccount=x12ef21", @"link", nil],
                                 [[NSDictionary alloc] initWithObjectsAndKeys: @"petco", @"img_name", @"Petco", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.petco.com/shop/UserRegistrationForm?new=Y&catalogId=10051&myAcctMain=1&langId=-1&postRegisterURL=https%3A%2F%2Fwww.petco.com%2Fshop%2FPalsRewardsandOffersView%3FcatalogId%3D10051&storeId=10151", @"link", nil],
                                 [[NSDictionary alloc] initWithObjectsAndKeys: @"panera_bread", @"img_name", @"Panera Bread", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.panerabread.com/en-us/company/meet-mypanera.html", @"link", nil],
                                 [[NSDictionary alloc] initWithObjectsAndKeys: @"gnc", @"img_name", @"GNC", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://mygncrewards.com/Enrollment/Enrollment/Enrollment", @"link", nil],
                                 [[NSDictionary alloc] initWithObjectsAndKeys: @"rite_aid", @"img_name", @"Rite Aid", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Pharmacy", @"category", @"http://www.riteaid.com/login", @"link", nil],nil];
    
    arr_travel_merchantAccounts = [[NSArray alloc] initWithObjects:
                                   [[NSDictionary alloc] initWithObjectsAndKeys: @"best_buy", @"img_name", @"Best Buy", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category",@"http://www-ssl.bestbuy.com/identity/signin?token=tid%3A97dc4efa-18be-11e7-a26d-005056920f07", @"link", nil],
                                   [[NSDictionary alloc] initWithObjectsAndKeys: @"best_buy", @"img_name", @"Best Buy", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category",@"http://www-ssl.bestbuy.com/identity/signin?token=tid%3A97dc4efa-18be-11e7-a26d-005056920f07", @"link", nil],
                                   
                                   [[NSDictionary alloc] initWithObjectsAndKeys: @"best_buy", @"img_name", @"Best Buy", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category",@"http://www-ssl.bestbuy.com/identity/signin?token=tid%3A97dc4efa-18be-11e7-a26d-005056920f07", @"link", nil],
                                   
                                   [[NSDictionary alloc] initWithObjectsAndKeys: @"best_buy", @"img_name", @"Best Buy", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category",@"http://www-ssl.bestbuy.com/identity/signin?token=tid%3A97dc4efa-18be-11e7-a26d-005056920f07", @"link", nil],
                                   
                                   [[NSDictionary alloc] initWithObjectsAndKeys: @"qfc", @"img_name", @"QFC", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.qfc.com/account/create", @"link", nil],
                                   [[NSDictionary alloc] initWithObjectsAndKeys: @"safe_way", @"img_name", @"Safeway", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.safeway.com/CMS/account/register/?bannerId=safeway&FullSite=Y&goto=http:%2F%2Fwww.safeway.com%2FShopStores%2FOffers-Landing-IMG.page%3Fcmpid%3Dco_kw_700000001291346_71700000013870022_58700001116047740_p10059066649%26gclid%3DCj0KEQjw5YfHBRDzjNnioYq3_swBEiQArj4pdL7HVMRLfqEMlJEJAoNqTQ2TjZDNloWGlIe08ve1OlkaAkCp8P8HAQ%26dclid%3DCOLKg5OvidMCFU93YgodseEE2w", @"link", nil],
                                   [[NSDictionary alloc] initWithObjectsAndKeys: @"ikea", @"img_name", @"Ikea", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://secure.ikea.com/webapp/wcs/stores/servlet/LogonForm?langId=-1&storeId=12&krypto=sNKhj2OZZ3reHy29UD646MsGt4eouJFP8etAz75yEZD7eGSf96cZ9SUOGmE1t%2B8bwabmMXuP2IzrP6CUKM2HyBLj22T9g9rx7KTrzeOBgEeD1mp447Bz69DTe8v9IoR8oBmGSurf5VYbZ05RpYGDIre3JKNVnTPMW7dR0qsX6KkbVvu8QOgVKzMPefspez4krFbIkSGvOtkat2kSxuC3Xgx%2BjKLNYaNQ67zr9secJoc%3D&ddkey=https%3AUpdateUser", @"link", nil],
                                   [[NSDictionary alloc] initWithObjectsAndKeys: @"pet_smart", @"img_name", @"Petsmart", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.petsmart.ca/account/", @"link", nil],
                                   [[NSDictionary alloc] initWithObjectsAndKeys: @"lowes", @"img_name", @"Lowe's", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.lowes.com/webapp/wcs/stores/servlet/UserRegistrationForm?storeId=10151&catalogId=10051&langId=-1&krypto=EJ2KE8BMfJumd8Uo7SMFi5S6sAXbnRxpIvsZirMfG4jgGEePe0BUQCI3jEAq%2BZDo7BfpXH3JU42WmZk4xhTkWr6U1CgIY7HurxCCu6tCDeWd6k3JKxk%2Bgzb5s8IOZCm%2Fhui9%2FOMopcC%2FxQHpDfbYDw%3D%3D", @"link", nil],
                                   [[NSDictionary alloc] initWithObjectsAndKeys: @"office_depot", @"img_name", @"Office Depot", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.officedepot.com/account/registrationDisplay.do", @"link", nil],
                                   [[NSDictionary alloc] initWithObjectsAndKeys: @"staples", @"img_name", @"Staples", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.staples.com/office/supplies/StaplesManageRegistration?catalogId=10051&langId=-1&storeId=10001&krypto=9YxXH2e6712%2B9tefHjLFu7ym8Wxl0IvJv2qHNorUZCYpKkBhZuw4a3pU6xK7M27NqMgxVgv8RbKAQM1NxaIZyA%3D%3D&ddkey=http%3AStaplesManageRegistration", @"link", nil],
                                   [[NSDictionary alloc] initWithObjectsAndKeys: @"thebodyshop", @"img_name", @"The Body Shop", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.thebodyshop.com/en-us/login?loginAccount=x12ef21", @"link", nil],
                                   [[NSDictionary alloc] initWithObjectsAndKeys: @"petco", @"img_name", @"Petco", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.petco.com/shop/UserRegistrationForm?new=Y&catalogId=10051&myAcctMain=1&langId=-1&postRegisterURL=https%3A%2F%2Fwww.petco.com%2Fshop%2FPalsRewardsandOffersView%3FcatalogId%3D10051&storeId=10151", @"link", nil],
                                   [[NSDictionary alloc] initWithObjectsAndKeys: @"panera_bread", @"img_name", @"Panera Bread", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://www.panerabread.com/en-us/company/meet-mypanera.html", @"link", nil],
                                   [[NSDictionary alloc] initWithObjectsAndKeys: @"gnc", @"img_name", @"GNC", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Home", @"category", @"http://mygncrewards.com/Enrollment/Enrollment/Enrollment", @"link", nil],
                                   [[NSDictionary alloc] initWithObjectsAndKeys: @"rite_aid", @"img_name", @"Rite Aid", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"Pharmacy", @"category", @"http://www.riteaid.com/login", @"link", nil],nil];
    
    // Shops Items
      // set the value of Rates @"null"
    arr_shops_merchantAccounts = [[NSArray alloc] initWithObjects:
                                     [[NSDictionary alloc] initWithObjectsAndKeys: @"wallgreens_logo", @"img_name", @"Walgreens", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"http://www.walgreens.com/register/regOptions.jsp", @"link", nil],
                                     [[NSDictionary alloc] initWithObjectsAndKeys: @"qfc", @"img_name", @"QFC", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"http://www.qfc.com/account/create", @"link", nil],
                                     [[NSDictionary alloc] initWithObjectsAndKeys: @"target", @"img_name", @"Target", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"http://www.target.com/", @"link", nil],
                                     [[NSDictionary alloc] initWithObjectsAndKeys: @"cvs_logo", @"img_name", @"CVS", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"http://www.cvs.com/", @"link", nil],
                                     [[NSDictionary alloc] initWithObjectsAndKeys: @"bartels_logo", @"img_name", @"Bartels", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"http://www.bartelldrugs.com/", @"link", nil],
                                     [[NSDictionary alloc] initWithObjectsAndKeys: @"safe_way", @"img_name", @"Safeway", @"title_name", @"null", @"rate_vip", @"null", @"rate_product", @"http://www.safeway.com/CMS/account/register/?bannerId=safeway&FullSite=Y&goto=http:%2F%2Fwww.safeway.com%2F", @"link", nil], nil];
    

    
    
    [FIRApp configure];
    
//    [[FBSDKApplicationDelegate sharedInstance] application:application
//                             didFinishLaunchingWithOptions:launchOptions];

    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    
    
    return YES;
}

- (void) initializeOfVar
{
    arrForLineGraphDataLastMonth = [[NSMutableArray alloc] init];
    arrForLineGraphDataCurrentMonth = [[NSMutableArray alloc] init];
    indexOfSelectedImageOfMerchantAccount = 0;
    indexOfSelectedMenu = 1;
    feedbackAddButtonAndBackButtonFlag = false;
    onceInitFlag = false;
    mUserID = @"";
    mUserEmail = @"";
    mUserName = @"";
    mFBProfile = nil;
    showChatFlag = false;
    isSelectedPlusButtonForHome = 0;
    maxAmount = 0.0;
    isMaxInLast = false;
    arrMerchantShops = [[NSMutableArray alloc] initWithCapacity: 30];
    arrMerchantEatings = [[NSMutableArray alloc] initWithCapacity: 30];
}

- (void) addMFSideMenu
{
    // MFSideMenu Controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    MFSideMenuContainerViewController *container = (MFSideMenuContainerViewController *)self.window.rootViewController;
    menuItems = [NSArray arrayWithObjects:
                 [NSDictionary dictionaryWithObjectsAndKeys: @"ZEAL", @"name", @"menu_icon_black", @"image", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys: @"Shopper Profile", @"name", self.mFBProfile, @"image", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys: @"My Stores", @"name", @"homebuttonbackground", @"image", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys: @"My Financials", @"name", @"financialbackground", @"image", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys: @"About", @"name", @"zeal_about_image", @"image", nil], nil];
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"navigationController"];
    UIViewController *leftSideMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"leftSideMenuViewController"];
    
    [container setLeftMenuViewController:leftSideMenuViewController];
    [container setCenterViewController:navigationController];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    // This is the Facebook or Google+ SDK returning to the app after authentication.
//    return [[FBSDKApplicationDelegate sharedInstance] application:application
//                                                          openURL:url
//                                                sourceApplication:sourceApplication
//                                                       annotation:annotation];
//}

#pragma GoogleSignin
- (BOOL)application:(nonnull UIApplication *)application
            openURL:(nonnull NSURL *)url
            options:(nonnull NSDictionary<NSString *, id> *)options {
    return [self application:application
                     openURL:url
            // [START new_options]
           sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                  annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[GIDSignIn sharedInstance] handleURL:url];
}

@end
