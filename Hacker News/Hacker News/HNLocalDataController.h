//
//  HNLocalDataController.h
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/13.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>
#import "HNStory.h"
#import "HNComment.h"

@interface HNLocalDataController : NSObject

+ (instancetype)sharedLocalDataController;

- (void)createTableIfNeeded;
- (void)insertComment:(HNComment *)comment;
- (NSMutableArray *)getCommentsByStoryId:(NSUInteger)storyId;
- (void)deleteCommentsByStoryId:(NSUInteger)storyId;

@end
