//
//  MerchantHome.m
//  Zeal
//
//  Created by P1 on 5/29/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import "MerchantHome.h"
#import "CustomTableViewCell2.h"
#import "AppDelegate.h"
@import Firebase;

#define PRODUCT_KEY @"Product Discounts"
#define VIP_KEY @"VIP Service"

@interface MerchantHome ()
{
    FIRDatabaseReference *mFirebaseDBReference;
    NSString *strRateVIP, *strRateProduct;
    AppDelegate *app;
}
@end

@implementation MerchantHome
@synthesize table_view;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    app = (AppDelegate *) [UIApplication sharedApplication].delegate;
    [table_view registerNib: [UINib nibWithNibName: @"CustomTableViewCell2" bundle:nil] forCellReuseIdentifier: @"cell2"];
    strRateVIP = @"null";
    strRateProduct = @"null";
    
    NSString *userID = [[[FIRAuth auth] currentUser] uid];
    mFirebaseDBReference = [[[[FIRDatabase database] reference] child: userID] child: @"rate_db_home"];
    
    if (mFirebaseDBReference != nil) {
        
        [mFirebaseDBReference observeSingleEventOfType:(FIRDataEventTypeValue) withBlock: ^(FIRDataSnapshot *_Nonnull snapshot) {
            if ([snapshot exists]) {
                
                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray: app.arr_home_merchantAccounts];
                for (snapshot in snapshot.children) {
                    NSString *key = snapshot.key;
                    
                    for (int i = 0; i < tempArray.count; i ++) {
                        NSDictionary *rowInArray = [tempArray objectAtIndex: i];
                        if ([key isEqualToString: [rowInArray objectForKey: @"title_name"]]) {
                            strRateVIP = [snapshot.value objectForKey: VIP_KEY];
                            strRateProduct = [snapshot.value objectForKey: PRODUCT_KEY];
                            NSString *oldLogoStr = [rowInArray objectForKey: @"img_name"];
                            [tempArray replaceObjectAtIndex: i withObject:
                             [[NSDictionary alloc] initWithObjectsAndKeys: oldLogoStr, @"img_name", key, @"title_name", strRateVIP, @"rate_vip", strRateProduct, @"rate_product", nil]];
                        }
                    }
                    
                }
                
                app.arr_home_merchantAccounts = [[NSArray alloc] initWithArray: tempArray];
                [table_view reloadData];
                
            }
        }];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [app.arr_home_merchantAccounts count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier: @"cell2" forIndexPath:indexPath];
    NSDictionary *dic = [app.arr_home_merchantAccounts objectAtIndex: indexPath.row];
    cell.titleLabel.text = [dic objectForKey: @"title_name"];
    cell.subTitleLabel.text = [dic objectForKey: @"category"];
    
    strRateProduct = [dic objectForKey: @"rate_product"];
    strRateVIP = [dic objectForKey: @"rate_vip"];
    
    cell.ratingView.hidden = YES;
    if (![strRateVIP isEqualToString: @"null"] && ![strRateProduct isEqualToString: @"null"]) {
        cell.vipHCStarRatingView.value = [strRateVIP floatValue];
        cell.productHCStarRatingView.value = [strRateProduct floatValue];
        cell.ratingView.hidden = NO;
    }
    
    cell.plus_button.tag = indexPath.row + 100;
    
    cell.iconImageView.image = [UIImage imageNamed:  [dic objectForKey: @"img_name"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [app.arr_home_merchantAccounts objectAtIndex: indexPath.row];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [dic objectForKey: @"link"]]];
}

@end
