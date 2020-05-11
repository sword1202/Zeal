//
//  PlaidAPIViewController.h
//  Zeal
//
//  Created by P1 on 6/7/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaidAPIViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>
{
    __weak IBOutlet UITableView *table_view;
    __weak IBOutlet UITableView *tableViewOfTransactions;
    
}

@property (weak, nonatomic) IBOutlet UIWebView *webview;

-(NSMutableDictionary*)dictionaryFromLinkUrl:(NSURL*)linkURL;
-(NSURL*)generateLinkInitializationURLWithOptions:(NSDictionary*)options;

@end
