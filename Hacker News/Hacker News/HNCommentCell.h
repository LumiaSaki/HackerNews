//
//  HNCommentCell.h
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/9.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNCommentCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *authorButton;
@property (nonatomic, weak) IBOutlet UILabel *commentLabel;

@end
