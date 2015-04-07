//
//  HNComment.m
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/7.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import "HNComment.h"

@implementation HNComment

- (instancetype)initWithAuthor:(NSString *)author commentId:(NSUInteger)commentId subComments:(NSArray *)subComments parent:(NSUInteger)parent contentText:(NSString *)contentText time:(NSDate *)time type:(NSString *)type {
    self = [super init];
    if (self) {
        _author = author;
        _commentId = commentId;
        _subComments = subComments;
        _parent = parent;
        _contentText = contentText;
        _time = time;
        _type = type;
    }
    return self;
}
@end
