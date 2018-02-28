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
#import "ToastHelper.h"
#import "AFHTTPSessionManager.h"
#import "SquareHttpClient.h"

@import Firebase;

#define PRODUCT_KEY @"Product Discounts"
#define VIP_KEY @"VIP Service"

#define DESIRED_HEADER_HEIGHT 70
#define CELL_HEIGHT 50

@interface MerchantAccountCoffee () <UIPickerViewDelegate, UIPickerViewDataSource>
{
    FIRDatabaseReference *mFirebaseDBReference;
    NSMutableArray *arrOfTableView;
    AppDelegate *app;
    MBProgressHUD *hud;
    NSString *selectedSectionName;
    NSMutableDictionary *catalogItemsDic;
    NSString *selectedLocationID, *selectedCatalogObjID;
    SquareHttpClient *httpClientSquareup;
    NSMutableArray *ordersArr;
    __weak IBOutlet UIPickerView *cardPickerView;
    __weak IBOutlet UIView *cardPickerViewContainer;
    NSArray *linkedCards;
    NSString *selectedCardsStr;
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
    
    httpClientSquareup = [SquareHttpClient sharedSquareHttpClient];
    
    [self getCardsArray];
    
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
    
    mFirebaseDBReference = [baseDBRef child: kcoffeelist];
    
    if (mFirebaseDBReference != nil) {
//        [ToastHelper showLoading: self.view message: @"Loading ..."];
        [mFirebaseDBReference observeSingleEventOfType:(FIRDataEventTypeValue) withBlock: ^(FIRDataSnapshot *_Nonnull snapshot) {
            
//            [ToastHelper hideLoading];
            
            if ([snapshot exists]) {

                arrOfTableView = [[NSMutableArray alloc] initWithArray: snapshot.value];
                
                for (int i=0; i<[arrOfTableView count]; i++) {
                    [arrayForBoolOrder addObject:[NSNumber numberWithBool:NO]];
                    [arrForBoolHistory addObject:[NSNumber numberWithBool:NO]];
                }
                
                // get catagory items from squareup
//                [self getItemsFromSquareup];
                [table_view reloadData];
                
            }
        }];

    }
}

- (void) getCardsArray
{
    NSString *userID;
    userID = TEST_MODE==1 ? UID:[[[FIRAuth auth] currentUser] uid];
    
    [[[[baseDBRef child: kconsumers] child: userID] child: klinked_cards]
     observeSingleEventOfType: (FIRDataEventTypeValue) withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         if ([CommonUtils isNull: snapshot.value]) {
             return ;
         }
         
         linkedCards = snapshot.value;
         
         cardPickerView.delegate = self;
         cardPickerView.dataSource = self;
         
         selectedCardsStr = [linkedCards objectAtIndex: 0];
     }];
}

- (void) getItemsFromSquareup
{
    catalogItemsDic = [[NSMutableDictionary alloc] init];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSString *urlStr = @"https://connect.squareup.com/v2/catalog/list?types=item";
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET"
                            URLString: urlStr parameters:nil error:nil];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:[NSString stringWithFormat: @"Bearer %@", ACCESSTOKEN_SQUAREUP] forHTTPHeaderField:@"Authorization"];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:req completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
            NSDictionary *responseDic = (NSDictionary *) responseObject;
            NSArray *arrValue = [responseDic objectForKey: @"objects"];
            for (int i=0; i<arrValue.count;  i++) {
                NSDictionary *catalogDic = [arrValue objectAtIndex: i];
                NSString *itemID = [catalogDic objectForKey: @"id"];
                NSDictionary *itemDataDic = [catalogDic objectForKey: @"item_data"];
                NSString *itemName = [itemDataDic objectForKey: @"name"];
                
                // location id check
                NSArray *presentAtLocationIDs = [catalogDic objectForKey: @"present_at_location_ids"];
                for (int j=0; j<presentAtLocationIDs.count; j++) {
                    NSString *locationID = [presentAtLocationIDs objectAtIndex: j];
                    
                    NSDictionary *itemName_ID = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 itemID,   @"id",
                                                 itemName, @"name", nil];
                    [catalogItemsDic setObject: itemName_ID forKey: locationID];
                }
                
            }
            
            NSLog(@"%@", catalogItemsDic);
        }
    }];
    [dataTask resume];
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
        CoffeeObj *obj = [[CoffeeObj alloc] initWithDic:[arrOfTableView objectAtIndex: section]];
        NSArray *orderLists = obj.orderLists;
        if (orderLists.count <= 0) {
            // there is no orderlist
            return 2;
        } else
            return [orderLists count];
        
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
    
    BOOL manyCellsWhenOrder  = [[arrayForBoolOrder objectAtIndex:indexPath.section] boolValue];
    BOOL manyCellsWhenHistory  = [[arrForBoolHistory objectAtIndex:indexPath.section] boolValue];
    
    cell.orderView2.hidden = YES;
    cell.backgroundColor=[UIColor clearColor];
    /********** If the section supposed to be closed *******************/
    if(!manyCellsWhenOrder && !manyCellsWhenHistory)
    {
        cell.titleLabel.text=@"";
        
    }
    /********** If the section supposed to be Opened *******************/
    else if (manyCellsWhenOrder)
    {
        CoffeeObj *obj = [[CoffeeObj alloc] initWithDic:[arrOfTableView objectAtIndex: indexPath.section]];
        
        if (obj.orderLists.count <= 0) {
            cell.orderView.hidden = YES;
            cell.orderView2.hidden = NO;
            cell.historyView.hidden = YES;
            cell.layer.cornerRadius = 10;
            cell.layer.masksToBounds = true;
            if (indexPath.row == 0) {
                cell.order2_title.text = @"The Order feature is currently unavailable";
                cell.order2_detail.hidden = YES;
            } else
            {
                cell.order2_detail.hidden = NO;
                cell.order2_title.text = @"Zeal Users often save on average $00.00";
                cell.order2_detail.text = @"Sales often happen in September";
            }
            
        } else
        {
            
            cell.orderView.hidden = NO;
            cell.historyView.hidden = YES;
            NSDictionary *dic = [obj.orderLists objectAtIndex: indexPath.row];
            cell.titleLabel.text= [[dic allValues] objectAtIndex: 0];
            cell.titleLabel.textColor = [UIColor whiteColor];
            cell.backgroundColor=[UIColor clearColor];
            
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
            cell.icon_detali_label.hidden = YES;
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
                    cell.img_tickOfOrder.hidden = NO;
                    cell.largeImageView.image=[UIImage imageNamed:@"coffee_order_image"];
                    [cell.largeImageView addGestureRecognizer:orderCellIconTapped];
                    break;
                    
                default:
                    break;
            }
        }
        
    } else
    {
        cell.numberOfVisit.text = @"0";
        cell.avr_spendAmount.text = @"$ 0.00";
        
        // retrieving data from Database (Plaid)
        NSString *userID = TEST_MODE==1 ? UID:[[[FIRAuth auth] currentUser] uid];

        FIRDatabaseReference *dbRef = [[[baseDBRef child:kconsumers] child: userID] child: kFINANCIAL_DB];
        
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
                        cell.backgroundColor=[UIColor clearColor];
                    }
                } else
                {
                    
                    cell.orderView.hidden = YES;
                    cell.historyView.hidden = NO;
                    cell.backgroundColor=[UIColor clearColor];
                }
            }];
        } else
        {
            cell.orderView.hidden = YES;
            cell.historyView.hidden = NO;
            cell.backgroundColor=[UIColor clearColor];
        }
        
    }
    
    /********** Add a custom Separator with cell *******************/
//    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(15, CELL_HEIGHT, table_view.frame.size.width-30, 0.5)];
//    separatorLineView.backgroundColor = [UIColor blackColor];
//    [cell.contentView addSubview:separatorLineView];
    
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
    CoffeeObj *obj = [[CoffeeObj alloc] initWithDic: [arrOfTableView objectAtIndex: section]];
    UIView *sectionView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, table_view.frame.size.width-20,DESIRED_HEADER_HEIGHT)];
    
    UILabel *viewLabel=[[UILabel alloc]initWithFrame:CGRectMake(DESIRED_HEADER_HEIGHT, 10, table_view.frame.size.width-20, DESIRED_HEADER_HEIGHT-30)];
    viewLabel.backgroundColor=[UIColor clearColor];
    viewLabel.textColor=[UIColor whiteColor];
    viewLabel.font=[UIFont fontWithName: @"Roboto-Bold" size:16];
    viewLabel.text= obj.name;
    [sectionView addSubview:viewLabel];
    
    /********** Add "Order" Label *******************/
    UILabel *orderLabel=[[UILabel alloc]initWithFrame:CGRectMake(DESIRED_HEADER_HEIGHT, DESIRED_HEADER_HEIGHT-20, 100, 20)];
    orderLabel.backgroundColor=[UIColor clearColor];
    
    orderLabel.textColor=[UIColor blackColor];
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
    
    historyLabel.textColor=[UIColor blackColor];
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
    separatorLineView.backgroundColor = [UIColor whiteColor];
    [sectionView addSubview:separatorLineView];
    
    /********** Add UITapGestureRecognizer to SectionView   **************/
    
    UITapGestureRecognizer  *orderLabelTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectOrderLabel:)];
    [orderLabel addGestureRecognizer:orderLabelTapped];
    
    UITapGestureRecognizer  *historyLabelTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectHistoryLabel:)];
    [historyLabel addGestureRecognizer:historyLabelTapped];
    
    UIImage *image = [UIImage imageNamed: obj.imgName];
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
    CoffeeObj *obj = [[CoffeeObj alloc] initWithDic: [arrOfTableView objectAtIndex: mTag]];
    selectedSectionName = obj.name;
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
    
    int mTag = (int)gestureRecognizer.view.tag;
    int currentState = mTag%10; // small, medium, large
    int currentSection = mTag/100; // 0, 1, 2, ...
    int currentRow = mTag%100/10; //0, 1, 2, ... the number of Coffee Categories
    NSLog(@"Current Selected TAG : %d", mTag);
    NSIndexPath *indexPathToReload = [NSIndexPath indexPathForRow:currentRow inSection:currentSection];
    
    CoffeeObj *selectedObj = [[CoffeeObj alloc] initWithDic:[arrOfTableView objectAtIndex: currentSection]];
    
    switch (currentState) {
        case 0:
        {
            // if small
            logoState = MEDIUM;
            
            // create order for catalog items
            NSDictionary *selectedCatalogItemDic = [selectedObj.orderLists objectAtIndex: currentRow];
            NSString *itemName = [[selectedCatalogItemDic allValues] objectAtIndex: 0];
            selectedLocationID = selectedObj.location_id;
            selectedCatalogObjID = [[selectedCatalogItemDic allKeys]  objectAtIndex: 0];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Order Confirmation"
                                                            message:[NSString stringWithFormat: @"Are you sure you want to order '%@'?", itemName]
                                                           delegate:self
                                                  cancelButtonTitle:@"Yes"
                                                  otherButtonTitles:@"No", nil];
            [alert show];
        }
            
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //Code for Yes button
        if ([CommonUtils isNull: selectedLocationID] || [CommonUtils isNull: selectedCatalogObjID]) {
            return;
        }
        
        [self createOrder];
    }
    if (buttonIndex == 1)
    {
        //Code for No button
    }
}

- (void) createOrder
{
    cardPickerViewContainer.hidden = false;
    
}

- (IBAction)didSelectCard:(id)sender {
    
    FIRDatabaseReference *ordersRef = [[baseDBRef child: kOrders] child: selectedCardsStr];
    ordersArr = [NSMutableArray new];
    if (![CommonUtils isNull: selectedCardsStr]) {
        cardPickerViewContainer.hidden = YES;
        
        [self showProgressBar: @"Creating Order..."];
        
        [httpClientSquareup createOrderwithlocationid: selectedLocationID catalog_obj_id: selectedCatalogObjID
                                withCompletionHandler:^(NSInteger responseCode, NSDictionary *order) {
            if (responseCode == 200) {
                
                [ordersRef observeSingleEventOfType: (FIRDataEventTypeValue) withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                    if ([CommonUtils isNull: snapshot.value]) {
                        
                        [ordersArr addObject:order];
                        [ordersRef setValue: ordersArr];
                        
                    } else
                    {
                        ordersArr = snapshot.value;
                        
                        for (int i=0; i<ordersArr.count; i++) {
                            NSDictionary *everyOrder = [ordersArr objectAtIndex: i];
                            NSArray *lineItems = [everyOrder objectForKey: @"line_items"];
                            
                            NSArray *newlineItems = [order objectForKey: @"line_items"];
                            
                            if ([CommonUtils compare2Arrays:lineItems array2:newlineItems]) {
                                // same order
                                [ordersArr removeObjectAtIndex: i];
                                break;
                            }
                        }
                        
                        [ordersArr addObject:order];
                        [ordersRef setValue: ordersArr];
                    }
                    
                    
                    hud.hidden = YES;
                    
                    [ToastHelper showToast: @"Order has been created successfully."];
                }];
                
            } else
            {
                hud.hidden = YES;
                [ToastHelper showToast: @"Something went wrong."];
            }
        }];
    }
}

#pragma mark PickerView Delegate and DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    return linkedCards.count;
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [linkedCards objectAtIndex:row];
    return title;
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedCardsStr = [linkedCards objectAtIndex:row];
}


@end
