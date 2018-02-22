//
//  ToastHelper.h
//  Zeal
//
//  Created by P1 on 5/25/17.
//  Copyright © 2017 ZealOfCnorth2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ToastHelper : NSObject

+ (void) showToast: (NSString *) message;
+ (void) showLoading: (UIView *) view message : (NSString *) message;
+ (void) hideLoading;

@end
