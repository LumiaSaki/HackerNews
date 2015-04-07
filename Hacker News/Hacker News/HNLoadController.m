//
//  HNLoadController.m
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/7.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import "HNLoadController.h"

static NSString *TOP_STORIES_URL = @"https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty";

static NSString *ITEM_URL_PREFIX = @"https://hacker-news.firebaseio.com/v0/item/";
static NSString *STORY_URL_SUFFIX = @".json?print=pretty";

static NSString *USER_URL_PREFIX = @"https://hacker-news.firebaseio.com/v0/user/";
static NSString *USER_URL_SUFFIX = @".json?print=pretty";

@implementation HNLoadController

+ (instancetype)sharedLoadController {
    static dispatch_once_t token;
    static HNLoadController *loadController;
    dispatch_once(&token, ^{
        loadController = [[HNLoadController alloc]init];
    });
    return loadController;
}

- (void)loadTopStories:(void (^)(NSArray *, BOOL))completionHandler {
    NSURL *url = [NSURL URLWithString:TOP_STORIES_URL];
    
    [self dataFromURL:url completionHandler:^(NSData *data) {
        if (data != nil) {
            NSError *jsonError;
            
            NSArray *topStoriesId = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (topStoriesId != nil && !jsonError) {
                NSMutableArray *topStoriesArray = [NSMutableArray new];
                
                for (NSNumber *topStoryId in topStoriesId) {
                    HNStory *story = [[HNStory alloc]initWithAuthor:nil descendants:0 storyId:[topStoryId unsignedIntegerValue] comments:nil score:0 time:nil title:nil type:nil url:nil];
                    
                    [topStoriesArray addObject:story];
                }
                
                for (HNStory *aStory in topStoriesArray) {
                    [self loadStoryById:aStory.storyId completionHandler:^(HNStory *story, BOOL success) {
                        aStory.author = story.author;
                        aStory.descendants = story.descendants;
                        aStory.comments = story.comments;
                        aStory.score = story.score;
                        aStory.time = story.time;
                        aStory.title = story.title;
                        aStory.type = story.type;
                        aStory.url = story.url;
                    }];
                }
                completionHandler(topStoriesArray, YES);
            } else {
                completionHandler(nil, NO);
            }
        }
    }];
}

- (void)loadStoryById:(NSUInteger)storyId completionHandler:(void (^)(HNStory *, BOOL))completionHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%lu%@", ITEM_URL_PREFIX, (unsigned long)storyId, STORY_URL_SUFFIX]];
    
    [self dataFromURL:url completionHandler:^(NSData *data) {
        if (data != nil) {
            NSError *jsonError;
            
            NSDictionary *storyDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (storyDict != nil && !jsonError) {
                HNStory *story = [[HNStory alloc]initWithAuthor:storyDict[@"by"] descendants:[storyDict[@"descendants"] unsignedIntegerValue] storyId:[storyDict[@"id"] unsignedIntegerValue] comments:storyDict[@"kids"] score:[storyDict[@"score"] unsignedIntegerValue] time:[NSDate dateWithTimeIntervalSince1970:[storyDict[@"time"] unsignedIntegerValue]] title:storyDict[@"title"] type:storyDict[@"type"] url:storyDict[@"url"]];
                
                completionHandler(story, YES);
            } else {
                completionHandler(nil, NO);
            }
        }
    }];
}

- (void)loadUserById:(NSString *)userId completionHandler:(void (^)(HNUser *, BOOL))completionHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",USER_URL_PREFIX,userId,USER_URL_SUFFIX]];
    
    [self dataFromURL:url completionHandler:^(NSData *data) {
        if (data != nil) {
            NSError *jsonError;
            
            NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (userDict != nil && !jsonError) {
                HNUser *user = [[HNUser alloc] initWithAbout:userDict[@"about"] createDate:[NSDate dateWithTimeIntervalSince1970:[userDict[@"created"] unsignedIntegerValue]] delay:[userDict[@"delay"] unsignedIntegerValue] userId:userDict[@"id"] karma:[userDict[@"karma"] unsignedIntegerValue] submitted:userDict[@"submitted"]];
                
                completionHandler(user, YES);
            } else {
                completionHandler(nil, NO);
            }
        }
    }];
}

#pragma mark - Private methods

- (void)dataFromURL:(NSURL *)url completionHandler:(void (^)(NSData *data))completionHandler {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"GET";
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            completionHandler(data);
        } else {
            //handle error
            completionHandler(nil);
        }
    }];
    
    [dataTask resume];
}
@end
