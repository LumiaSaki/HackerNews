//
//  HNStoryDetailShareBarButtonItem.m
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/10.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import "HNStoryDetailLoadIndicatorBarButtonItem.h"

@implementation HNStoryDetailLoadIndicatorBarButtonItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        rightButton.frame = CGRectMake(0, 0, 30, 30);
        
        [rightButton addSubview:_indicator];
        
        rightButton.userInteractionEnabled = NO;
        
        [self setCustomView:rightButton];
    }
    return self;
}

@end
