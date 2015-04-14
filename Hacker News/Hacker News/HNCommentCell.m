//
//  HNCommentCell.m
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/9.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import "HNCommentCell.h"

@implementation HNCommentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[authorLabel]-8-[commentLabel]-8-|" options:0 metrics:nil views:@{ @"commentLabel": self.commentLabel , @"authorLabel" : self.authorButton}]];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
//    _commentLabel.preferredMaxLayoutWidth = CGRectGetWidth(_commentLabel.frame);
}

- (IBAction)authorButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AuthorButtonInCommentPressed" object:self userInfo:@{@"userId" : _authorButton.titleLabel.text}];
}
@end
