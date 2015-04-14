//
//  HNCommentStoryCell.m
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/9.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import "HNCommentStoryCell.h"

@implementation HNCommentStoryCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)sourceButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StorySourceButtonPressed" object:self];
}

- (IBAction)authorButtonPressed:(id)sender {
    NSString *authorName = [[[_storyAuthorButton.titleLabel.text componentsSeparatedByString:@":"] lastObject] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StoryAuthorButtonPressed" object:self userInfo:@{@"userId" : authorName}];
}

@end
