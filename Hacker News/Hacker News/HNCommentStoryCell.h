//
//  HNCommentStoryCell.h
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/9.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNCommentStoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *storyTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *storyAuthorButton;
@end
