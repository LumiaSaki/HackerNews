//
//  TopStoryTableViewCell.h
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/7.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HNTopStoryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *clickCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

@end
