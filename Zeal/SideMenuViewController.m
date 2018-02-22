//
//  SideMenuViewController.m
//  Zeal
//
//  Created by P1 on 6/12/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "MainViewController.h"
#import "AppDelegate.h"

@interface SideMenuViewController ()
{
    AppDelegate *app;
}
@end

@implementation SideMenuViewController

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    app = (AppDelegate *) [UIApplication sharedApplication].delegate;
    
    return app.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        for (NSString *familyName in [UIFont familyNames]) {
            for (NSString *fontName in [UIFont fontNamesForFamilyName: familyName]) {
                NSLog( @"\t%@", fontName);
            }
        }
        cell.textLabel.font = [UIFont fontWithName: @"KohinoorTelugu-Regular" size: 12.0f];
        
    }
    NSDictionary *dic = [app.menuItems objectAtIndex: indexPath.row];
    cell.imageView.image = [UIImage imageNamed: @"right_logo"];
    cell.imageView.alpha = 0.0;
    UIImageView *iv = [[UIImageView alloc] initWithFrame:(CGRectMake(20, 20, tableView.rowHeight-40, tableView.rowHeight-40))];
    
    if (indexPath.row == 1 && app.mFBProfile != nil) {
        iv.image = app.mFBProfile;
    } else
    {
        iv.image = [UIImage imageNamed: [dic objectForKey: @"image"]];
    }
    
    iv.contentMode =  UIViewContentModeScaleAspectFit;
    [cell.contentView addSubview:iv];

    cell.textLabel.text = [dic objectForKey: @"name"];
    
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath: indexPath animated:YES];
    
    if (indexPath.row == 0) {
        return;
    }
    
    app.indexOfSelectedMenu = (int)indexPath.row;
    
    MainViewController *mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainViewController"];
//    mainViewController.title = [[app.menuItems objectAtIndex: indexPath.row] objectForKey: @"name"];
    
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    NSArray *controllers = [NSArray arrayWithObject:mainViewController];
    navigationController.viewControllers = controllers;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

@end
