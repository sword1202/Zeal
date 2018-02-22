//
//  MerchantTravelViewController.m
//  Zeal
//
//  Created by P1 on 11/23/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import "MerchantTravelViewController.h"
#import "CustomCellForCoffeeTableViewCell.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
@import Firebase;

#define PRODUCT_KEY @"Product Discounts"
#define VIP_KEY @"VIP Service"

#define DESIRED_HEADER_HEIGHT 70
#define CELL_HEIGHT 50


@interface MerchantTravelViewController ()
{
    FIRDatabaseReference *mFirebaseDBReference;
    NSString *strRateVIP, *strRateProduct;
    NSMutableArray *arrOfTableView;
    AppDelegate *app;
    MBProgressHUD *hud;
    NSString *selectedSectionName;
}

@end

@implementation MerchantTravelViewController
@synthesize table_view;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) showProgressBar: (NSString *) message
{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = message;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrayForBoolOrder = [[NSMutableArray alloc] init];
    arrForBoolHistory = [[NSMutableArray alloc] init];
    cellNameArrayOfOrder = [[NSArray alloc] initWithObjects:
                            @"Flat White",
                            @"CAPPUCCINO ",
                            @"AMERICANO",
                            @"LATTE",
                            @"LATTE MACCHIATO",
                            nil];
    
    cellNameArrayOfHistory = [[NSArray alloc] initWithObjects:
                              @"History 1",
                              @"History 2",
                              @"History 3",
                              nil];
    logoState = 1; // small
    
    app = (AppDelegate *) [UIApplication sharedApplication].delegate;
    table_view.delegate = self;
    table_view.dataSource = self;
    [table_view registerNib: [UINib nibWithNibName: @"CustomCellForCoffeeTableViewCell" bundle:nil] forCellReuseIdentifier: @"cell_coffee"];
    strRateVIP = @"null";
    strRateProduct = @"null";
    
    arrOfTableView = [[NSMutableArray alloc] initWithArray: app.arr_travel_merchantAccounts];
    for (int i=0; i<[arrOfTableView count]; i++) {
        [arrayForBoolOrder addObject:[NSNumber numberWithBool:NO]];
        [arrForBoolHistory addObject:[NSNumber numberWithBool:NO]];
    }
    
//    NSString *userID = [[[FIRAuth auth] currentUser] uid];
//    mFirebaseDBReference = [[[[FIRDatabase database] reference] child: userID] child: @"rate_db_home"];
//    
//    if (mFirebaseDBReference != nil) {
//        
//        [mFirebaseDBReference observeSingleEventOfType:(FIRDataEventTypeValue) withBlock: ^(FIRDataSnapshot *_Nonnull snapshot) {
//            if ([snapshot exists]) {
//                
//                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray: app.arr_travel_merchantAccounts];
//                for (snapshot in snapshot.children) {
//                    NSString *key = snapshot.key;
//                    
//                    for (int i = 0; i < tempArray.count; i ++) {
//                        NSDictionary *rowInArray = [tempArray objectAtIndex: i];
//                        if ([key isEqualToString: [rowInArray objectForKey: @"title_name"]]) {
//                            strRateVIP = [snapshot.value objectForKey: VIP_KEY];
//                            strRateProduct = [snapshot.value objectForKey: PRODUCT_KEY];
//                            NSString *oldLogoStr = [rowInArray objectForKey: @"img_name"];
//                            NSString *oldSubStr = [rowInArray objectForKey: @"category"];
//                            NSString *oldlink = [rowInArray objectForKey: @"link"];
//                            [tempArray replaceObjectAtIndex: i withObject:
//                             [[NSDictionary alloc] initWithObjectsAndKeys: oldLogoStr, @"img_name", key, @"title_name", oldSubStr, @"category", strRateVIP, @"rate_vip", strRateProduct, @"rate_product", oldlink, @"link", nil]];
//                        }
//                    }
//                    
//                }
//                
//                app.arr_travel_merchantAccounts = [[NSArray alloc] initWithArray: tempArray];
//                //                [table_view reloadData];
//                
//            }
//        }];
//        
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return DESIRED_HEADER_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([[arrayForBoolOrder objectAtIndex:section] boolValue]) {
        return 2;
    } else if ([[arrForBoolHistory objectAtIndex:section] boolValue])
    {
        // return array of history
        return 1;
    }
    else
        return 0;
    
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [arrOfTableView count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCellForCoffeeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell_coffee" forIndexPath:indexPath];
    NSDictionary *dic = [app.arr_travel_merchantAccounts objectAtIndex: indexPath.row];
    
    BOOL manyCellsWhenOrder  = [[arrayForBoolOrder objectAtIndex:indexPath.section] boolValue];
    BOOL manyCellsWhenHistory  = [[arrForBoolHistory objectAtIndex:indexPath.section] boolValue];
    
    /********** If the section supposed to be closed *******************/
    cell.orderView.hidden = YES;
    if(!manyCellsWhenOrder && !manyCellsWhenHistory)
    {
        cell.backgroundColor=[UIColor clearColor];
        
        cell.titleLabel.text=@"";
        
    }
    /********** If the section supposed to be Opened *******************/
    else if (manyCellsWhenOrder)
    {
        cell.orderView2.hidden = NO;
        cell.historyView.hidden = YES;
        cell.layer.cornerRadius = 10;
        cell.layer.masksToBounds = true;
        if (indexPath.row == 0) {
            cell.orderView2.backgroundColor=[UIColor whiteColor];
            cell.order2_title.text = @"The Order feature is currently unavailable";
            cell.order2_detail.hidden = YES;
        } else
        {
            cell.order2_detail.hidden = NO;
            cell.orderView2.backgroundColor=[UIColor groupTableViewBackgroundColor];
            cell.order2_title.text = @"Zeal Users often save on average $ 155.0";
            cell.order2_detail.text = @"Sales often happen in September";
        }
    } else
    {
        cell.numberOfVisit.text = @"0";
        cell.avr_spendAmount.text = @"$ 0.00";
        
        // retrieving data from Database (Plaid)
        NSString *userID = TEST_MODE==1 ? UID:[[[FIRAuth auth] currentUser] uid];
        
        FIRDatabaseReference *dbRef = [[[[[FIRDatabase database] reference] child:@"consumers"] child: userID] child: @"financial_db"];
        
        if (dbRef != nil) {
            [self showProgressBar: @"Retrieving Transactions..."];
            [dbRef observeSingleEventOfType:(FIRDataEventTypeValue) withBlock: ^(FIRDataSnapshot *_Nonnull snapshot) {
                
                hud.hidden = YES;
                if ([snapshot exists]) {
                    //                    NSMutableArray *arr_currentMonthTransactions = [[NSMutableArray alloc] init];
                    int transactionCount = 0;
                    CGFloat transactionsOfThisMonth = 0.0;
                    for (snapshot in snapshot.children) {
                        NSDictionary *dic = snapshot.value;
                        NSArray *currentTransactions = [dic objectForKey: @"transactions"];
                        NSDictionary *everyTransaction;
                        for (int i=0; i<currentTransactions.count; i++) {
                            everyTransaction = [currentTransactions objectAtIndex:i];
                            NSArray *category = [everyTransaction objectForKey: @"category"];
                            NSString *transactionName = @"";
                            if (category != nil) {
                                transactionName = [category objectAtIndex: 0];
                                NSLog(@"--- %@ ---", transactionName);
                                if ([transactionName isEqualToString: selectedSectionName]) {
                                    transactionCount++;
                                    transactionsOfThisMonth += [[everyTransaction objectForKey: @"amount"] floatValue];
                                }
                            }
                            
                            
                        }
                        
                        if (transactionCount != 0) {
                            // average amount per month
                            transactionsOfThisMonth = transactionsOfThisMonth/transactionCount;
                            cell.numberOfVisit.text = [NSString stringWithFormat: @"%d", transactionCount];
                            cell.avr_spendAmount.text = [NSString stringWithFormat: @"$ %.2f", transactionsOfThisMonth];
                        }
                        cell.orderView2.hidden = YES;
                        cell.historyView.hidden = NO;
                        cell.backgroundColor=[UIColor whiteColor];
                    }
                } else
                {
                    
                    cell.orderView2.hidden = YES;
                    cell.historyView.hidden = NO;
                    cell.backgroundColor=[UIColor whiteColor];
                }
            }];
        } else
        {
            cell.orderView2.hidden = YES;
            cell.historyView.hidden = NO;
            cell.backgroundColor=[UIColor whiteColor];
        }
        
    }
    
    //    strRateProduct = [dic objectForKey: @"rate_product"];
    //    strRateVIP = [dic objectForKey: @"rate_vip"];
    //
    //    cell.ratingView.hidden = YES;
    //    cell.titleLabel.hidden = YES;
    //    cell.subTitleLabel.hidden = YES;
    //    if (![strRateVIP isEqualToString: @"null"] && ![strRateProduct isEqualToString: @"null"]) {
    //        cell.vipHCStarRatingView.value = [strRateVIP floatValue];
    //        cell.productHCStarRatingView.value = [strRateProduct floatValue];
    //        cell.ratingView.hidden = NO;
    //        cell.titleLabel.hidden = NO;
    //        cell.subTitleLabel.hidden = NO;
    //        cell.titleLabel.text = [dic objectForKey: @"title_name"];
    //        cell.subTitleLabel.text = [dic objectForKey: @"category"];
    //        cell.titleLabel_noReview.hidden = YES;
    //        cell.subTitleLabel_noReview.hidden = YES;
    //        [cell.plus_button setImage: [UIImage imageNamed: @"tick"] forState: UIControlStateNormal];
    //        [cell.plus_button setUserInteractionEnabled: NO];
    //    } else
    //    {
    //        cell.titleLabel_noReview.text = [dic objectForKey: @"title_name"];
    //        cell.subTitleLabel_noReview.text = [dic objectForKey: @"category"];
    //        [cell.plus_button setImage: [UIImage imageNamed: @"plus"] forState: UIControlStateNormal];
    //        [cell.plus_button setUserInteractionEnabled: YES];
    //        cell.plus_button.tag = indexPath.row + 100;
    //    }
    
    
    
    //    cell.iconImageView.image = [UIImage imageNamed:  [dic objectForKey: @"img_name"]];
    //    [self drawCircleIcon: cell.iconImageView];
    return cell;
}

- (void) createBaseLine: (UILabel *) mLabel
{
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.borderColor = [UIColor grayColor].CGColor;
    border.frame = CGRectMake(0, mLabel.frame.size.height - borderWidth, mLabel.frame.size.width, mLabel.frame.size.height);
    border.borderWidth = borderWidth;
    [mLabel.layer addSublayer: border];
    mLabel.layer.masksToBounds = YES;
}

- (void) drawCircleIcon: (UIImageView *) mImageView
{
    mImageView.layer.cornerRadius = 25;
    mImageView.clipsToBounds = YES;
    mImageView.layer.backgroundColor=[[UIColor clearColor] CGColor];
    mImageView.layer.borderWidth=2.0;
    mImageView.layer.masksToBounds = YES;
    mImageView.layer.borderColor=[[UIColor blackColor] CGColor];
}

- (void) makeWrapContentLabel: (UILabel *) mLabel
{
    CGSize maximumLabelSize = CGSizeMake(100, 50);
    
    CGSize expectedLabelSize = [mLabel.text sizeWithFont:mLabel.font constrainedToSize:maximumLabelSize lineBreakMode:mLabel.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = mLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    newFrame.size.width = expectedLabelSize.width;
    mLabel.frame = newFrame;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    [tableView deselectRowAtIndexPath: indexPath animated:YES];
    //    NSDictionary *dic = [app.arr_home_merchantAccounts objectAtIndex: indexPath.row];
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [dic objectForKey: @"link"]]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[arrayForBoolOrder objectAtIndex:indexPath.section] boolValue]
        || [[arrForBoolHistory objectAtIndex:indexPath.section] boolValue]) {
        return CELL_HEIGHT;
    }
    return 0;
    
}

#pragma mark - Creating View for TableView Section

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, table_view.frame.size.width-20,DESIRED_HEADER_HEIGHT)];
    
    UILabel *viewLabel=[[UILabel alloc]initWithFrame:CGRectMake(DESIRED_HEADER_HEIGHT, 10, table_view.frame.size.width-20, DESIRED_HEADER_HEIGHT-30)];
    viewLabel.backgroundColor=[UIColor clearColor];
    viewLabel.textColor=[UIColor blackColor];
    viewLabel.font=[UIFont fontWithName: @"Roboto-Bold" size:16];
    viewLabel.text=[[arrOfTableView objectAtIndex: section] objectForKey:@"title_name"];
    [sectionView addSubview:viewLabel];
    
    /********** Add "Order" Label *******************/
    UILabel *orderLabel=[[UILabel alloc]initWithFrame:CGRectMake(DESIRED_HEADER_HEIGHT, DESIRED_HEADER_HEIGHT-20, 100, 20)];
    orderLabel.backgroundColor=[UIColor clearColor];
    
    orderLabel.textColor=[UIColor grayColor];
    orderLabel.font=[UIFont systemFontOfSize:13];
    orderLabel.tag=section;
    orderLabel.userInteractionEnabled = YES;
    orderLabel.text= @"Order";
    
    [self makeWrapContentLabel: orderLabel];
    
    if ([[arrayForBoolOrder objectAtIndex:section] boolValue]) {
        [self createBaseLine: orderLabel];
    } else
        logoState = 1;
    [sectionView addSubview:orderLabel];
    
    /********** Add "History" Label *******************/
    UILabel *historyLabel=[[UILabel alloc]initWithFrame:CGRectMake(table_view.frame.size.width - DESIRED_HEADER_HEIGHT, DESIRED_HEADER_HEIGHT-20, 100, 20)];
    historyLabel.backgroundColor=[UIColor clearColor];
    
    historyLabel.textColor=[UIColor grayColor];
    historyLabel.font=[UIFont systemFontOfSize:13];
    historyLabel.tag=section;
    historyLabel.userInteractionEnabled = YES;
    historyLabel.text= @"History";
    
    [self makeWrapContentLabel: historyLabel];
    
    if ([[arrForBoolHistory objectAtIndex:section] boolValue]) {
        [self createBaseLine: historyLabel];
    }
    [sectionView addSubview:historyLabel];
    
    /********** Add a custom Separator with Section view *******************/
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(10, DESIRED_HEADER_HEIGHT, table_view.frame.size.width-20, 1)];
    separatorLineView.backgroundColor = [UIColor grayColor];
    [sectionView addSubview:separatorLineView];
    
    /********** Add UITapGestureRecognizer to SectionView   **************/
    
    UITapGestureRecognizer  *orderLabelTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectOrderLabel:)];
    [orderLabel addGestureRecognizer:orderLabelTapped];
    
    UITapGestureRecognizer  *historyLabelTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectHistoryLabel:)];
    [historyLabel addGestureRecognizer:historyLabelTapped];
    
    UIImage *image = [UIImage imageNamed: [[arrOfTableView objectAtIndex: section] objectForKey:@"img_name"]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    
    imageView.backgroundColor = [UIColor redColor];
    imageView.frame = CGRectMake(10, 10, 50, 50);
    [self drawCircleIcon: imageView];
    [sectionView addSubview: imageView];
    
    return  sectionView;
    
    
}


#pragma mark - Table header gesture tapped

- (void)didSelectOrderLabel:(UITapGestureRecognizer *)gestureRecognizer{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:gestureRecognizer.view.tag];
    if (indexPath.row == 0) {
        
        BOOL collapsed  = [[arrayForBoolOrder objectAtIndex:indexPath.section] boolValue];
        for (int i=0; i<[arrOfTableView count]; i++) {
            if (indexPath.section==i) {
                [arrayForBoolOrder replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:!collapsed]];
                if ([[arrForBoolHistory objectAtIndex:indexPath.section] boolValue]) {
                    [arrForBoolHistory replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
                }
            }
            
        }
        
        [table_view reloadSections:[NSIndexSet indexSetWithIndex:gestureRecognizer.view.tag] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    
}

- (void)didSelectHistoryLabel:(UITapGestureRecognizer *)gestureRecognizer{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:gestureRecognizer.view.tag];
    int mTag = (int)gestureRecognizer.view.tag;
    selectedSectionName = [[arrOfTableView objectAtIndex: mTag] objectForKey:@"title_name"];
    if (indexPath.row == 0) {
        BOOL collapsed  = [[arrForBoolHistory objectAtIndex:indexPath.section] boolValue];
        for (int i=0; i<[arrOfTableView count]; i++) {
            if (indexPath.section==i) {
                [arrForBoolHistory replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:!collapsed]];
                if ([[arrayForBoolOrder objectAtIndex:indexPath.section] boolValue]) {
                    [arrayForBoolOrder replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
                }
            }
        }
        
        [table_view reloadSections:[NSIndexSet indexSetWithIndex:gestureRecognizer.view.tag] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    
}

- (void)didSelectOrderCellLogo:(UITapGestureRecognizer *)gestureRecognizer{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:gestureRecognizer.view.tag];
    int mTag = (int)gestureRecognizer.view.tag;
    int currentState = mTag%10; // small, medium, large
    int currentSection = mTag/100; // 0, 1, 2, ...
    int currentRow = mTag%100/10; //0, 1, 2, ... the number of Coffee Categories
    NSLog(@"Current Selected TAG : %d", mTag);
    NSIndexPath *indexPathToReload = [NSIndexPath indexPathForRow:currentRow inSection:currentSection];
    
    switch (currentState) {
        case 0:
            // if small
            logoState = 2;
            break;
            
        case 1:
            // if medium
            logoState = 3;
            break;
            
        case 2:
            // if large
            logoState = 1;
            break;
            
        default:
            break;
    }
    
    [table_view reloadRowsAtIndexPaths: [NSArray arrayWithObjects: indexPathToReload, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

@end
