//
//  MainViewController.h
//  Zeal
//
//  Created by P1 on 5/23/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;
@import GoogleSignIn;

//@import FBSDKCoreKit;
//@import FBSDKLoginKit;

@interface LoginViewController : UIViewController <GIDSignInDelegate>

- (IBAction)didSelectFacebookLogin:(id)sender;
@end
