//
//  HNComment.m
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/7.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import "HNUser.h"

@implementation HNUser

- (instancetype)initWithAbout:(NSString *)about createDate:(NSDate *)createDate delay:(NSUInteger)delay userId:(NSString *)userId karma:(NSUInteger)karma submitted:(NSArray *)submitted {
    self = [super init];
    if (self) {
        _about = about;
        _createDate = createDate;
        _delay = delay;
        _userId = userId;
        _karma = karma;
        _submitted = submitted;
    }
    return self;
}

@end
