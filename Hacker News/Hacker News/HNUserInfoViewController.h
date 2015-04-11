//
//  HNUserInfoViewController.h
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/10.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNUserInfoViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UITextView *aboutLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdLabel;
@property (weak, nonatomic) IBOutlet UILabel *delayLabel;
@property (weak, nonatomic) IBOutlet UILabel *karmaLabel;

@property (nonatomic, strong) NSString *userId;

@end
