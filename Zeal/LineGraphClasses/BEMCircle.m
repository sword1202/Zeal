//
//  BEMCircle.m
//  SimpleLineGraph
//
//  Created by Bobo on 12/27/13. Updated by Sam Spencer on 1/11/14.
//  Copyright (c) 2013 Boris Emorine. All rights reserved.
//  Copyright (c) 2014 Sam Spencer.
//

#import "BEMCircle.h"

@implementation BEMCircle

- (instancetype)initWithFrame:(CGRect)frame monthFlag: (int) mMonthFlag{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.month_flag = mMonthFlag;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    
    if (self.month_flag == 1) {
        [[UIColor colorWithRed: 0 green:150.0f/255.0f blue:1 alpha:1] set];
    } else if (self.month_flag == 0)
        [[UIColor greenColor] set];
    CGContextFillPath(ctx);
}

@end
