//
//  MerchantPharmacy.m
//  Zeal
//
//  Created by P1 on 5/29/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import "MerchantPharmacy.h"
#import "CustomTableViewCell2.h"
#import "AppDelegate.h"
@import Firebase;

#define PRODUCT_KEY @"Product Discounts"
#define VIP_KEY @"VIP Service"

@interface MerchantPharmacy ()
{
    FIRDatabaseReference *mFirebaseDBReference;
    NSString *strRateVIP, *strRateProduct;
    
    AppDelegate *app;
}
@end

@implementation MerchantPharmacy
@synthesize table_view;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.frame = [super view].frame;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Do any additional setup after loading the view from its nib.
    [table_view registerNib: [UINib nibWithNibName: @"CustomTableViewCell2" bundle:nil] forCellReuseIdentifier: @"cell2"];
    strRateVIP = @"null";
    strRateProduct = @"null";
    
    
    NSString *userID = [[[FIRAuth auth] currentUser] uid];
    mFirebaseDBReference = [[[[FIRDatabase database] reference] child: userID] child: @"rate_db_pharmacy"];
    
    if (mFirebaseDBReference != nil) {
        
        [mFirebaseDBReference observeSingleEventOfType:(FIRDataEventTypeValue) withBlock: ^(FIRDataSnapshot *_Nonnull snapshot) {
            if ([snapshot exists]) {
                
                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray: app.arr_pharmacy_merchantAccounts];
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
                
                app.arr_pharmacy_merchantAccounts = [[NSArray alloc] initWithArray: tempArray];
                [table_view reloadData];
                
            }
        }];
        
    }
    
    [self createBaseLineOfButton];
    
}

- (void) createBaseLineOfButton
{
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.borderColor = [UIColor blackColor].CGColor;
    border.frame = CGRectMake(0, btn_addMore.frame.size.height - borderWidth, btn_addMore.frame.size.width, btn_addMore.frame.size.height);
    border.borderWidth = borderWidth;
    [btn_addMore.layer addSublayer: border];
    btn_addMore.layer.masksToBounds = YES;
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
    return app.arr_pharmacy_merchantAccounts.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier: @"cell2" forIndexPath:indexPath];
    NSDictionary *dic = [app.arr_pharmacy_merchantAccounts objectAtIndex: indexPath.row];
    cell.titleLabel.text = [dic objectForKey: @"title_name"];
    cell.subTitleLabel.text = @"Pharmacy";
    
    strRateProduct = [dic objectForKey: @"rate_product"];
    strRateVIP = [dic objectForKey: @"rate_vip"];
    
    cell.ratingView.hidden = YES;
    if (![strRateVIP isEqualToString: @"null"] && ![strRateProduct isEqualToString: @"null"]) {
        cell.vipHCStarRatingView.value = [strRateVIP floatValue];
        cell.productHCStarRatingView.value = [strRateProduct floatValue];
        cell.ratingView.hidden = NO;
    }
    
    cell.plus_button.tag = indexPath.row + 200;
    
    cell.iconImageView.image = [UIImage imageNamed: [dic objectForKey: @"img_name"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog( @"%d --- '%d'", (int)indexPath.row, (int)tableView.tag);
    [tableView deselectRowAtIndexPath: indexPath animated:YES];
    NSDictionary *selectedDic = [app.arr_pharmacy_merchantAccounts objectAtIndex: indexPath.row];
    NSString *directURLSTR = [selectedDic objectForKey: @"link"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directURLSTR]];
}

- (IBAction)didSelectAddMorePrograms:(id)sender {
    NSLog(@"Add More Accounts...");
}
@end
