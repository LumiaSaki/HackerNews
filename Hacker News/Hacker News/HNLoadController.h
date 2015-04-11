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
#import "HNComment.h"

@interface HNLoadController : NSObject

+ (instancetype)sharedLoadController;

//- (void)loadStorieByItemIdArray:(NSArray *)itemIdArray fromIndex:(NSUInteger)fromIndex fetchStoriesCount:(NSUInteger)fetchStoriesCount completionHandler:(void(^)(NSMutableArray *storiesArray, NSInteger lastStoryIndex))completionHandler;

- (void)loadStorieByItemIdArray:(NSArray *)itemIdArray fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex completionHandler:(void (^)(NSMutableArray *itemArray))completionHandler;
- (void)loadStoriesByIdArray:(NSArray *)storiesIdArray fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex completionHandler:(void (^)(NSArray *stories))completionHandler;
- (void)loadTopStoriesFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex completionHandler:(void (^)(NSArray *topStories))completionHandler;
- (void)loadStoryById:(NSUInteger)storyId completionHandler:(void(^)(HNStory *story))completionHandler;
- (void)loadUserById:(NSString *)userId completionHandler:(void(^)(HNUser *user))completionHandler;
- (void)loadAllCommentsUnderStoryId:(NSUInteger)storyId completionHandler:(void (^)(NSMutableDictionary *commentsDict))completionHandler;
@end
