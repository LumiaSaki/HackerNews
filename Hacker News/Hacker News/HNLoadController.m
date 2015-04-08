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
static NSString *USER_URL_PREFIX = @"https://hacker-news.firebaseio.com/v0/user/";

static NSString *URL_SUFFIX = @".json?print=pretty";

@implementation HNLoadController

+ (instancetype)sharedLoadController {
    static dispatch_once_t token;
    static HNLoadController *loadController;
    
    dispatch_once(&token, ^{
        loadController = [[HNLoadController alloc]init];
    });
    
    return loadController;
}

- (void)loadTopStoriesFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex completionHandler:(void (^)(NSArray *))completionHandler {
    NSURL *url = [NSURL URLWithString:TOP_STORIES_URL];
    
    [self dataFromURL:url completionHandler:^(NSData *data) {
        if (data != nil) {
            NSError *jsonError;
            
            NSArray *topStoriesId = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (topStoriesId != nil && !jsonError) {
                NSMutableArray *topStoriesArray = [NSMutableArray new];

                for (NSUInteger i = fromIndex ; i <= MIN(toIndex, [topStoriesId count] - 1) ; i++) {
                    HNStory *story = [[HNStory alloc] initWithAuthor:nil descendants:0 storyId:[topStoriesId[i] unsignedIntegerValue] comments:nil score:0 time:nil title:nil type:nil url:nil];
                    
                    [topStoriesArray addObject:story];
                }
                
                __block NSInteger completionCount = 0;
                
                for (HNStory *aStory in topStoriesArray) {
                    [self loadStoryById:aStory.storyId completionHandler:^(HNStory *story) {
                        aStory.author = story.author;
                        aStory.descendants = story.descendants;
                        aStory.comments = story.comments;
                        aStory.score = story.score;
                        aStory.time = story.time;
                        aStory.title = story.title;
                        aStory.type = story.type;
                        aStory.url = story.url;
                        
                        completionCount += 1;
                        
                        if (completionCount == [topStoriesArray count]) {
                            completionHandler(topStoriesArray);
                        }
                    }];
                }
            } else {
                completionHandler(nil);
            }
        } else {
            completionHandler(nil);
        }
    }];
}

- (void)loadStoryById:(NSUInteger)storyId completionHandler:(void (^)(HNStory *))completionHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%lu%@", ITEM_URL_PREFIX, (unsigned long)storyId, URL_SUFFIX]];
    
    [self dataFromURL:url completionHandler:^(NSData *data) {
        if (data != nil) {
            NSError *jsonError;
            
            NSDictionary *storyDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (storyDict != nil && !jsonError) {
                HNStory *story = [[HNStory alloc] initWithAuthor:storyDict[@"by"] descendants:[storyDict[@"descendants"] unsignedIntegerValue] storyId:[storyDict[@"id"] unsignedIntegerValue] comments:storyDict[@"kids"] score:[storyDict[@"score"] unsignedIntegerValue] time:[NSDate dateWithTimeIntervalSince1970:[storyDict[@"time"] unsignedIntegerValue]] title:storyDict[@"title"] type:storyDict[@"type"] url:storyDict[@"url"]];
                
                completionHandler(story);
            } else {
                completionHandler(nil);
            }
        } else {
            completionHandler(nil);
        }
    }];
}

- (void)loadUserById:(NSString *)userId completionHandler:(void (^)(HNUser *))completionHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",USER_URL_PREFIX,userId,URL_SUFFIX]];
    
    [self dataFromURL:url completionHandler:^(NSData *data) {
        if (data != nil) {
            NSError *jsonError;
            
            NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (userDict != nil && !jsonError) {
                HNUser *user = [[HNUser alloc] initWithAbout:userDict[@"about"] createDate:[NSDate dateWithTimeIntervalSince1970:[userDict[@"created"] unsignedIntegerValue]] delay:[userDict[@"delay"] unsignedIntegerValue] userId:userDict[@"id"] karma:[userDict[@"karma"] unsignedIntegerValue] submitted:userDict[@"submitted"]];
                
                completionHandler(user);
            } else {
                completionHandler(nil);
            }
        } else {
            completionHandler(nil);
        }
    }];
}

- (void)loadAllCommentsUnderStoryId:(NSUInteger)storyId completionHandler:(void (^)(NSArray *))completionHandler {
    [self loadStoryById:storyId completionHandler:^(HNStory *story) {
        NSMutableArray *comments = [NSMutableArray new];
        
        [self loadCommentsFromCommentsIdArray:story.comments toArray:comments depth:0];
        
        completionHandler(comments);
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

- (void)loadCommentById:(NSUInteger)commentId completionHandler:(void(^)(HNComment *comment))completionHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%lu%@",ITEM_URL_PREFIX,(unsigned long)commentId,URL_SUFFIX]];
    
    [self dataFromURL:url completionHandler:^(NSData *data) {
        if (data != nil) {
            NSError *jsonError;
            
            NSDictionary *commentDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (commentDict != nil && !jsonError) {
                HNComment *comment = [[HNComment alloc] initWithAuthor:commentDict[@"by"] commentId:[commentDict[@"id"] unsignedIntegerValue] subComments:commentDict[@"kids"] parent:[commentDict[@"parent"] unsignedIntegerValue] contentText:commentDict[@"text"] time:[NSDate dateWithTimeIntervalSince1970:[commentDict[@"time"] unsignedIntegerValue]] type:commentDict[@"type"] depth:0];
                
                completionHandler(comment);
            } else {
                completionHandler(nil);
            }
        } else {
            completionHandler(nil);
        }
    }];
}

//TODO:Wait for debugging. may be some errors in it.
- (void)loadCommentsFromCommentsIdArray:(NSArray *)commentsIdArray toArray:(NSMutableArray *)array depth:(NSUInteger)depth {
    for (NSNumber *commentId in commentsIdArray) {
        [self loadCommentById:[commentId unsignedIntegerValue] completionHandler:^(HNComment *comment) {
            if (comment != nil) {
                comment.depth = depth;
                [array addObject:comment];
                
                if ([comment.subComments count] != 0) {
                    [self loadCommentsFromCommentsIdArray:comment.subComments toArray:array depth:depth + 1];
                }
            }
        }];
    }
}

@end
