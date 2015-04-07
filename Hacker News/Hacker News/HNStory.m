//
//  Story.m
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/7.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import "HNStory.h"

@implementation HNStory

- (instancetype)initWithAuthor:(NSString *)author descendants:(NSUInteger)descendants storyId:(NSUInteger)storyId comments:(NSArray *)comments score:(NSUInteger)score time:(NSDate *)time title:(NSString *)title type:(NSString *)type url:(NSString *)url {
    self = [super init];
    if (self) {
        _author = author;
        _descendants = descendants;
        _storyId = storyId;
        _comments = comments;
        _score = score;
        _time = time;
        _title = title;
        _type = type;
        _url = url;
    }
    return self;
}


@end
