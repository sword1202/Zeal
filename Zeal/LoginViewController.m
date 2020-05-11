//
//  MainViewController.m
//  Zeal
//
//  Created by P1 on 5/23/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "ToastHelper.h"
#import "UIViewController+Alerts.h"
#import "HomeViewController.h"
@import Firebase;

static NSString * const kFirebaseURL = @"https://zeal-915b2.firebaseio.com";

#define profilePermission @"public_profile"
#define emailPermission @"email"
#define friendPermission @"user_friends"
@interface LoginViewController ()
{
    __weak IBOutlet UIButton *loginButton;
    NSUserDefaults *userDefaults;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController setNavigationBarHidden:YES];
//    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
}

- (IBAction)didSelectFacebookLogin:(id)sender {
    
//    UIButton *button = sender;
//    button.userInteractionEnabled = NO;
//    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
////    [loginManager logInWithReadPermissions: [@"publick_profile", @"email"] fromViewController:self handler]
//    
//    [loginManager logInWithReadPermissions:@[emailPermission] fromViewController: self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//        button.userInteractionEnabled = YES;
//        if (error) {
//            // Process error
//            [self showMessagePrompt:error.localizedDescription];
//            NSLog(@"Error %@", error.localizedDescription);
//        } else if (result.isCancelled) {
//            // Handle cancellations
//            [self showMessagePrompt: @"Facebook login cancelled."];
//            NSLog(@"Facebook login cancelled.");
//        } else {
//            // If you ask for multiple permissions at once, you
//            // should check if specific permissions missing
//            
//            [ToastHelper showLoading: self.view message: @"Logging in..."];
//            
//            if ([FBSDKAccessToken currentAccessToken]) {
//                
//                [self signInFirebase: [FBSDKAccessToken currentAccessToken].tokenString];
//                
//            }
//            
//            
//        }
//    }];
    [GIDSignIn sharedInstance].presentingViewController = self;
    [[GIDSignIn sharedInstance] signIn];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    
    if (error == nil) {
        [ToastHelper showLoading: self.view message: @"Signing in..."];
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        
        
        [[FIRAuth auth] signInWithCredential:credential completion:^(FIRAuthDataResult * _Nullable fDataResult, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error %@", error.localizedDescription);
            } else
            {
                // store the credential to remove current user later
//                NSLog( @"email: %@", fDataResult.credential.);
                NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
                [userdefaults setObject:authentication.idToken forKey:@"authcredential_idToken"];
                [userdefaults setObject: authentication.accessToken forKey:@"authcredential_accessToken"];
                [userdefaults synchronize];
                
                [self firebaseLoginWithCredential:credential];
                
            }
        }];
        
    } else {
        // ...
        [self showMessagePrompt:error.localizedDescription];
    }
}

- (void)firebaseLoginWithCredential:(FIRAuthCredential *)credential {
    
    FIRUser *user = [FIRAuth auth].currentUser;
    if (user != nil) {
        
        NSString *mUserName = user.displayName;
//        NSString *mUserEmail = user.email;
        FIRDatabaseReference *dbRef = [baseDBRef child:kconsumers];
        [[[dbRef child:user.uid] child: @"name"] setValue: mUserName];
//        [[[dbRef child:user.uid] child: @"email"] setValue: mUserEmail];
        
        [ToastHelper hideLoading];
        [self gotoProfilePage];
        
    }
}

- (void) signInFirebase: (NSString *) accessToken
{
//    userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject: accessToken forKey: @"access_token"];
//    [userDefaults synchronize];
//    NSString *saved = [userDefaults objectForKey: @"access_token"];
//    FIRAuthCredential *credential = [FIRFacebookAuthProvider credentialWithAccessToken:accessToken];
//
//    //            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
//    //             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//    //
//    //                 if (!error) {
//    //                     NSLog(@"fetched user:%@  and Email : %@", result,result[@"email"]);
//    //                 } else
//    //                 {
//    //                     [self showMessagePrompt:error.localizedDescription];
//    //                 }
//    //             }];
//
//    [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
//        [ToastHelper hideLoading];
//        if (error) {
//            [self showMessagePrompt:error.localizedDescription];
//            NSLog(@"Error %@", error.localizedDescription);
//        } else
//        {
//            [self gotoProfilePage];
//
//        }
//    }];
}

- (void) gotoProfilePage
{
    [self.navigationController popViewControllerAnimated: NO];
    
//    MainViewController *main = [self.storyboard instantiateViewControllerWithIdentifier:@"mainViewController"];
//    [main setModalPresentationStyle:UIModalPresentationCustom];
//    [main setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
//    [self presentViewController:main animated:YES completion:nil];
}

@end
