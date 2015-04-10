//
//  HNStoryDetailViewController.h
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/9.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HNLoadController.h"

@interface HNStoryDetailViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic, strong) HNStory *story;

@end
