//
//  MerchantAccountCoffee.m
//  Zeal
//
//  Created by P1 on 7/4/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import "MerchantAccountCoffee.h"
#import "CustomCellForCoffeeTableViewCell.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
@import Firebase;

#define PRODUCT_KEY @"Product Discounts"
#define VIP_KEY @"VIP Service"

#define DESIRED_HEADER_HEIGHT 70
#define CELL_HEIGHT 50

@interface MerchantAccountCoffee ()
{
    FIRDatabaseReference *mFirebaseDBReference;
    NSString *strRateVIP, *strRateProduct;
    NSMutableArray *arrOfTableView;
    AppDelegate *app;
    MBProgressHUD *hud;
    NSString *selectedSectionName;
}
@end

@implementation MerchantAccountCoffee
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
    
    logoState = SMALL;
    app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // Do any additional setup after loading the view from its nib.
    table_view.delegate = self;
    table_view.dataSource = self;
    [table_view registerNib: [UINib nibWithNibName: @"CustomCellForCoffeeTableViewCell" bundle:nil] forCellReuseIdentifier: @"cell_coffee"];
    strRateVIP = @"null";
    strRateProduct = @"null";
    arrOfTableView = [[NSMutableArray alloc] initWithArray: app.arr_coffee_merchantAccounts];
    for (int i=0; i<[arrOfTableView count]; i++) {
        [arrayForBoolOrder addObject:[NSNumber numberWithBool:NO]];
        [arrForBoolHistory addObject:[NSNumber numberWithBool:NO]];
    }
    NSString *userID = [[[FIRAuth auth] currentUser] uid];
    mFirebaseDBReference = [[[[FIRDatabase database] reference] child: userID] child: @"rate_db_coffee"];
    
    if (mFirebaseDBReference != nil) {
        
        [mFirebaseDBReference observeSingleEventOfType:(FIRDataEventTypeValue) withBlock: ^(FIRDataSnapshot *_Nonnull snapshot) {
            if ([snapshot exists]) {
                
                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray: app.arr_coffee_merchantAccounts];
                for (snapshot in snapshot.children) {
                    NSString *key = snapshot.key;
                    
                    for (int i = 0; i < tempArray.count; i ++) {
                        NSDictionary *rowInArray = [tempArray objectAtIndex: i];
                        if ([key isEqualToString: [rowInArray objectForKey: @"title_name"]]) {
                            strRateVIP = [snapshot.value objectForKey: VIP_KEY];
                            strRateProduct = [snapshot.value objectForKey: PRODUCT_KEY];
                            NSString *oldLogoStr = [rowInArray objectForKey: @"img_name"];
                            NSString *oldLink = [rowInArray objectForKey: @"link"];
                            [tempArray replaceObjectAtIndex: i withObject:
                             [[NSDictionary alloc] initWithObjectsAndKeys: oldLogoStr, @"img_name", key, @"title_name", strRateVIP, @"rate_vip", strRateProduct, @"rate_product", oldLink, @"link", nil]];
                        }
                    }
                    
                }
                
                app.arr_coffee_merchantAccounts = [[NSArray alloc] initWithArray: tempArray];
//                [table_view reloadData];
                
            }
        }];
        
    }
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
        return [cellNameArrayOfOrder count];
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
//    static NSString *cellid=@"cell_id";
//    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellid];
    
    NSDictionary *dic = [arrOfTableView objectAtIndex: indexPath.row];
//    [UIImage imageNamed: [dic objectForKey: @"img_name"]]
//    if (cell==nil) {
//        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellid];
//    }
    
    
    BOOL manyCellsWhenOrder  = [[arrayForBoolOrder objectAtIndex:indexPath.section] boolValue];
    BOOL manyCellsWhenHistory  = [[arrForBoolHistory objectAtIndex:indexPath.section] boolValue];
    
    cell.orderView2.hidden = YES;
    
    /********** If the section supposed to be closed *******************/
    if(!manyCellsWhenOrder && !manyCellsWhenHistory)
    {
        cell.backgroundColor=[UIColor clearColor];
        
        cell.titleLabel.text=@"";
        
    }
    /********** If the section supposed to be Opened *******************/
    else if (manyCellsWhenOrder)
    {
        cell.orderView.hidden = NO;
        cell.historyView.hidden = YES;
        
        cell.titleLabel.text= [cellNameArrayOfOrder objectAtIndex: indexPath.row];
        cell.backgroundColor=[UIColor whiteColor];
        
        // add tags for every order's section (sectionx100: 0, 100, 200...),
        // 5 items(40, 140, ...), small/medium/large (42, 142, 242, ...)
        
        cell.smallImageView.hidden = YES;
        cell.mediumImageView.hidden = YES;
        cell.largeImageView.hidden = YES;
        
        UITapGestureRecognizer  *orderCellIconTapped   =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectOrderCellLogo:)];
        [cell.smallImageView removeGestureRecognizer: orderCellIconTapped];
        [cell.mediumImageView removeGestureRecognizer: orderCellIconTapped];
        [cell.largeImageView removeGestureRecognizer: orderCellIconTapped];
        cell.img_tickOfOrder.hidden = YES;
        switch (logoState) {
            case SMALL:
                cell.smallImageView.tag = indexPath.section*100+indexPath.row*10;
                cell.smallImageView.hidden = NO;
                cell.icon_detali_label.text = @"Small";
                cell.smallImageView.image=[UIImage imageNamed:@"coffee_order_image"];
                [cell.smallImageView addGestureRecognizer:orderCellIconTapped];
                break;
            case MEDIUM:
                cell.mediumImageView.tag = indexPath.section*100+indexPath.row*10+1;
                cell.mediumImageView.hidden = NO;
                cell.icon_detali_label.text = @"Medium";
                cell.img_tickOfOrder.hidden = NO;
                cell.mediumImageView.image=[UIImage imageNamed:@"coffee_order_image"];
                [cell.mediumImageView addGestureRecognizer:orderCellIconTapped];
                break;
            case LARGE:
                cell.largeImageView.tag = indexPath.section*100+indexPath.row*10+2;
                cell.largeImageView.hidden = NO;
                cell.icon_detali_label.text = @"Large";
                cell.titleLabel.textColor = [UIColor blackColor];
                cell.img_tickOfOrder.hidden = NO;
                cell.largeImageView.image=[UIImage imageNamed:@"coffee_order_image"];
                [cell.largeImageView addGestureRecognizer:orderCellIconTapped];
                break;
                
            default:
                break;
        }
        
        
        
    } else
    {
        cell.numberOfVisit.text = @"0";
        cell.avr_spendAmount.text = @"$ 0.00";
        
        // retrieving data from Database (Plaid)
        NSString *userID = [[[FIRAuth auth] currentUser] uid];
        
//        userID = @"EGSKXZWM3COl253jke9bi5eCzSI3";
        FIRDatabaseReference *dbRef = [[[[FIRDatabase database] reference] child: userID] child: @"financial_db"];
        
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
                        cell.orderView.hidden = YES;
                        cell.historyView.hidden = NO;
                        cell.backgroundColor=[UIColor whiteColor];
                    }
                } else
                {
                    
                    cell.orderView.hidden = YES;
                    cell.historyView.hidden = NO;
                    cell.backgroundColor=[UIColor whiteColor];
                }
            }];
        } else
        {
            cell.orderView.hidden = YES;
            cell.historyView.hidden = NO;
            cell.backgroundColor=[UIColor whiteColor];
        }
        
    }
    
    /********** Add a custom Separator with cell *******************/
//    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(15, CELL_HEIGHT, table_view.frame.size.width-30, 0.5)];
//    separatorLineView.backgroundColor = [UIColor blackColor];
//    [cell.contentView addSubview:separatorLineView];
    
    return cell;
    
    
    
    
//    strRateProduct = [dic objectForKey: @"rate_product"];
//    strRateVIP = [dic objectForKey: @"rate_vip"];
//    
//    cell.ratingView.hidden = YES;
//    cell.titleLabel.hidden = YES;
//    cell.subTitleLabel.hidden = YES;
//    cell.historyLabel.hidden = NO;
//    
//    cell.titleLabel_noReview.text = [dic objectForKey: @"title_name"];
//    cell.subTitleLabel_noReview.text = @"Order";
//    [self createBaseLine:cell.subTitleLabel_noReview];
//    [cell.plus_button setImage: [UIImage imageNamed: @"plus"] forState: UIControlStateNormal];
//    [cell.plus_button setUserInteractionEnabled: YES];
//    cell.plus_button.tag = indexPath.row + 300;
    
//    if (![strRateVIP isEqualToString: @"null"] && ![strRateProduct isEqualToString: @"null"]) {
//        cell.vipHCStarRatingView.value = [strRateVIP floatValue];
//        cell.productHCStarRatingView.value = [strRateProduct floatValue];
//        cell.ratingView.hidden = NO;
//        cell.titleLabel.hidden = NO;
//        cell.subTitleLabel.hidden = NO;
//        [self createBaseLine:cell.subTitleLabel];
//        cell.titleLabel.text = [dic objectForKey: @"title_name"];
//        cell.subTitleLabel.text = @"Order";
//        cell.titleLabel_noReview.hidden = YES;
//        cell.subTitleLabel_noReview.hidden = YES;
//        [cell.plus_button setImage: [UIImage imageNamed: @"tick"] forState: UIControlStateNormal];
//        [cell.plus_button setUserInteractionEnabled: NO];
//    } else
//    {
//        cell.titleLabel_noReview.text = [dic objectForKey: @"title_name"];
//        cell.subTitleLabel_noReview.text = @"Order";
//        [self createBaseLine:cell.subTitleLabel_noReview];
//        [cell.plus_button setImage: [UIImage imageNamed: @"plus"] forState: UIControlStateNormal];
//        [cell.plus_button setUserInteractionEnabled: YES];
//        cell.plus_button.tag = indexPath.row + 300;
//    }
    
//    cell.plus_button.hidden = YES;
//    cell.iconImageView.image = [UIImage imageNamed: [dic objectForKey: @"img_name"]];
//    
////    if (indexPath.row == app.arr_coffee_merchantAccounts.count - 1) {
////        tableView.height = 320;
////    }
//    return cell;
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
    NSLog( @"%d --- '%d'", (int)indexPath.row, (int)tableView.tag);
    
    /*************** Close the section, once the data is selected ***********************************/
//    [arrayForBool replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithBool:NO]];
//    
//    [table_view reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];

    
//    [tableView deselectRowAtIndexPath: indexPath animated:YES];
//    NSDictionary *selectedDic = [app.arr_coffee_merchantAccounts objectAtIndex: indexPath.row];
//    NSString *directURLSTR = [selectedDic objectForKey: @"link"];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directURLSTR]];
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
        logoState = SMALL;
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
            logoState = MEDIUM;
            break;
            
        case 1:
            // if medium
            logoState = LARGE;
            break;
            
        case 2:
            // if large
            logoState = SMALL;
            break;
            
        default:
            break;
    }
    
    [table_view reloadRowsAtIndexPaths: [NSArray arrayWithObjects: indexPathToReload, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

@end
