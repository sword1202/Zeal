//
//  SplashScreen.m
//  Zeal
//
//  Created by P1 on 5/22/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "MainViewController.h"
@interface HomeViewController ()
{
    __weak IBOutlet UILabel *signInLabel;
}
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.borderColor = [UIColor blueColor].CGColor;
    border.frame = CGRectMake(0, signInLabel.frame.size.height - borderWidth, signInLabel.frame.size.width, signInLabel.frame.size.height);
    border.borderWidth = borderWidth;
    [signInLabel.layer addSublayer: border];
    signInLabel.layer.masksToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(gotoProfileView)];
    [signInLabel addGestureRecognizer:tap];
    
    // goto loginViewController if installed first this app
    
}

- (void) gotoProfileView
{
    MainViewController *main = [self.storyboard instantiateViewControllerWithIdentifier:@"mainViewController"];
    [main setModalPresentationStyle:UIModalPresentationCustom];
    [main setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:main animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
