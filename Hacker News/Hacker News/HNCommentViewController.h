//
//  HNCommentViewController.h
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/9.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HNLoadController.h"

@interface HNCommentViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSUInteger storyId;
@property (nonatomic, strong) NSString *storyTitle;
@property (nonatomic, strong) NSString *storyUrlString;
@property (nonatomic, strong) NSString *authorName;
@property (nonatomic) NSUInteger clickedCount;

@end
