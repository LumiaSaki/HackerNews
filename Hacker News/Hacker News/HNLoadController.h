//
//  HNLoadController.h
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/7.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HNStory.h"
#import "HNUser.h"

@interface HNLoadController : NSObject

+ (instancetype)sharedLoadController;

- (void)loadTopStories:(void(^)(NSArray *stories, BOOL success))completionHandler;  //stories<HNStory>
- (void)loadStoryById:(NSUInteger)storyId completionHandler:(void(^)(HNStory *story, BOOL success))completionHandler;   

////TODO:concern...
//- (void)loadCommentsById:(NSUInteger)commentId completionHandler:(void(^)(NSArray *comments, BOOL success))completionHandler;    //comments<HNComment>
- (void)loadUserById:(NSString *)userId completionHandler:(void(^)(HNUser *user, BOOL success))completionHandler;

@end
