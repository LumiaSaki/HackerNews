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

static NSUInteger count = 0;

@implementation HNLoadController

# pragma mark - Public Methods
/**
 *  单例方法
 *
 *  @return loadController单例
 */
+ (instancetype)sharedLoadController {
    static dispatch_once_t token;
    static HNLoadController *loadController;
    
    dispatch_once(&token, ^{
        loadController = [[HNLoadController alloc]init];
    });
    
    return loadController;
}

/**
 *  根据Id数组，从服务器请求部分Story
 *
 *  @param storiesIdArray    要请求的Story数组，该数组中的值是story id
 *  @param fromIndex         从Id数组中读取story的起始下标
 *  @param toIndex           从Id数组中读取story的终止下标
 *  @param completionHandler 将所有story请求回来的story放进数组，传给回调
 */
- (void)loadStoriesByIdArray:(NSArray *)storiesIdArray fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex completionHandler:(void (^)(NSArray *stories))completionHandler {
    if (storiesIdArray != nil) {
        NSMutableArray *storiesArray = [NSMutableArray new];
        
        for (NSUInteger i = fromIndex ; i <= MIN(toIndex, [storiesIdArray count] - 1) ; i++) {
            HNStory *story = [[HNStory alloc] initWithAuthor:nil descendants:0 storyId:[storiesIdArray[i] unsignedIntegerValue] comments:nil score:0 time:nil title:nil type:nil url:nil];
            
            [storiesArray addObject:story];
        }
        
        __block NSInteger completionCount = 0;
        
        for (HNStory *aStory in storiesArray) {
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
                
                if (completionCount == [storiesArray count]) {
                    completionHandler(storiesArray);
                }
            }];
        }
    } else {
        completionHandler(nil);
    }
}

/**
 *  根据Item Id数组，从服务器请求部分item，此方法Type不分Story或Comment
 *
 *  @param itemIdArray       要请求的item数组，该数组中值是item id
 *  @param fromIndex         从Id数组中读取item的起始下标
 *  @param toIndex           从Id数组中读取item的终止下标
 *  @param completionHandler 将所有请求回来的item放进数组，传给回调
 */
- (void)loadStoryOrCommentByItemIdArray:(NSArray *)itemIdArray fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex completionHandler:(void (^)(NSMutableArray *))completionHandler {
    NSMutableArray *itemArray = [NSMutableArray new];
    
    __block NSUInteger completionCount = 0;
    __block NSUInteger itemCount= 0;
    
    for (NSUInteger i = fromIndex; i <= MIN(toIndex, [itemIdArray count] - 1); i++) {
        NSNumber *itemId = itemIdArray[i];
        
        itemCount += 1;
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%ld%@", ITEM_URL_PREFIX, [itemId longValue], URL_SUFFIX]];
        
        [self dataFromURL:url completionHandler:^(NSData *data) {
            NSError *jsonError;
            
            NSDictionary *itemDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (itemDict != nil && !jsonError) {
                if ([itemDict[@"type"] isEqualToString:@"story"] /*&& ![itemDict[@"deleted"] isEqualToString:@"true"]*/) {
                    
                    HNStory *story = [[HNStory alloc] initWithAuthor:itemDict[@"by"] descendants:[itemDict[@"descendants"] unsignedIntegerValue] storyId:[itemDict[@"id"] unsignedIntegerValue] comments:itemDict[@"kids"] score:[itemDict[@"score"] unsignedIntegerValue] time:[NSDate dateWithTimeIntervalSince1970:[itemDict[@"time"] unsignedIntegerValue]] title:itemDict[@"title"] type:itemDict[@"type"] url:itemDict[@"url"]];
                    
                        [itemArray addObject:story];
                        
                        completionCount += 1;
                        
                        if (completionCount == itemCount) {
                            completionHandler(itemArray);
                        }
                } else if ([itemDict[@"type"] isEqualToString:@"comment"] /*&& ![itemDict[@"deleted"] isEqualToString:@"true"]*/) {
                    HNComment *comment = [[HNComment alloc] initWithAuthor:itemDict[@"by"] commentId:[itemDict[@"id"] unsignedIntegerValue] subComments:itemDict[@"kids"] parent:[itemDict[@"parent"] unsignedIntegerValue] contentText:itemDict[@"text"] time:[NSDate dateWithTimeIntervalSince1970:[itemDict[@"time"] unsignedIntegerValue]] type:itemDict[@"type"] depth:0];
                    
                    [itemArray addObject:comment];
                    
                    completionCount += 1;
                    
                    if (completionCount == itemCount) {
                        completionHandler(itemArray);
                    }
                }
            } else {
                //handle json error and dict is nil.
                completionHandler(nil);
            }
        }];
    }
}

/**
 *  请求部分Top Story实体，此方法使用了封装好的loadStoriesByIdArray:fromIndex:toIndex:completionHandler:
 *
 *  @param fromIndex         请求Top Story的起始下标
 *  @param toIndex           请求Top Story的终止下标
 *  @param completionHandler 将请求返回的数据包装成NSArray<HNStory>数组传给回调
 */
- (void)loadTopStoriesFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex completionHandler:(void (^)(NSArray *))completionHandler {
    NSURL *url = [NSURL URLWithString:TOP_STORIES_URL];
    
    [self dataFromURL:url completionHandler:^(NSData *data) {
        if (data != nil) {
            NSError *jsonError;
            
            NSArray *topStoriesId = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (!jsonError) {
                [self loadStoriesByIdArray:topStoriesId fromIndex:fromIndex toIndex:toIndex completionHandler:^(NSArray *stories) {
                    completionHandler(stories);
                }];
            } else {
                completionHandler(nil);
            }
        } else {
            completionHandler(nil);
        }
    }];
}

/**
 *  请求一个story
 *
 *  @param storyId           要请求的story id
 *  @param completionHandler 将请求返回的数据反序列化为HNStory传给回调
 */
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

/**
 *  请求一个user
 *
 *  @param userId            要请求的user id
 *  @param completionHandler 将请求返回的数据反序列化为HNUser传给回调
 */
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

/**
 *  请求同一个story id下的所有comment
 *
 *  @param storyId           要请求的story id
 *  @param completionHandler 将返回的数据反序列化为NSMutableDictionary<comment.id, HNComment>
 */
- (void)loadAllCommentsUnderStoryId:(NSUInteger)storyId completionHandler:(void (^)(NSMutableDictionary *))completionHandler {
    [self loadStoryById:storyId completionHandler:^(HNStory *story) {
        NSMutableDictionary *comments = [NSMutableDictionary new];
        
        [self loadCommentsFromCommentsIdArray:story.comments toDict:comments depth:0 underStoryId:storyId completionHandler:^(NSMutableDictionary *comments) {
            completionHandler(comments);
        }];
    }];
}

#pragma mark - Private methods

/**
 *  根据url请求网络资源
 *
 *  @param url               要请求的url
 *  @param completionHandler 将远端服务器返回的应答数据（NSData）传给回调
 */
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

/**
 *  读取一条comment
 *
 *  @param commentId         要请求的comment id
 *  @param underStoryId      comment所属哪一个story id下
 *  @param completionHandler 将请求返回的数据反序列化为HNComment，传给回调
 */
- (void)loadCommentById:(NSUInteger)commentId underStoryId:(NSUInteger)underStoryId completionHandler:(void(^)(HNComment *comment))completionHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%lu%@",ITEM_URL_PREFIX,(unsigned long)commentId,URL_SUFFIX]];
    
    [self dataFromURL:url completionHandler:^(NSData *data) {
        if (data != nil) {
            NSError *jsonError;
            
            NSDictionary *commentDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (commentDict != nil && !jsonError) {
                HNComment *comment = [[HNComment alloc] initWithAuthor:commentDict[@"by"] commentId:[commentDict[@"id"] unsignedIntegerValue] subComments:commentDict[@"kids"] parent:[commentDict[@"parent"] unsignedIntegerValue] contentText:commentDict[@"text"] time:[NSDate dateWithTimeIntervalSince1970:[commentDict[@"time"] unsignedIntegerValue]] type:commentDict[@"type"] depth:0 ];
                
                comment.underStoryId = underStoryId;
                
                completionHandler(comment);
            } else {
                completionHandler(nil);
            }
        } else {
            completionHandler(nil);
        }
    }];
}

/**
 *  根据一个comment id数组，递归请求所有该comment id数组下所有的comment，包括comment's comment
 *
 *  @param commentsIdArray   要请求的comment id数组
 *  @param dict              以comment id为key，comment为value的字典，用于存储多个HNComment实体，该处作为参数是用于将该字典递归传递下去
 *  @param depth             记录当前comment在递归中的层级，用以标示回复的层级关系
 *  @param underStoryId      标示在是在哪一个story id下的comment
 *  @param completionHandler 将请求返回的包含所有comment数据的dict传递给回调
 */
- (void)loadCommentsFromCommentsIdArray:(NSArray *)commentsIdArray toDict:(NSMutableDictionary *)dict depth:(NSUInteger)depth underStoryId:(NSUInteger)underStoryId completionHandler:(void(^)(NSMutableDictionary *commentsDict))completionHandler {
    
    for (NSNumber *commentId in commentsIdArray) {
        count ++;
        [self loadCommentById:[commentId unsignedIntegerValue] underStoryId:underStoryId completionHandler:^(HNComment *comment) {
                if (comment != nil) {
                    comment.depth = depth;
                    comment.underStoryId = underStoryId;
                    
                    [dict setValue:comment forKey:[NSString stringWithFormat:@"%lu", (unsigned long)[commentId unsignedIntegerValue]]];
                    
                    if ([comment.subComments count] != 0) {
                        [self loadCommentsFromCommentsIdArray:comment.subComments toDict:dict depth:depth + 1 underStoryId:underStoryId completionHandler:completionHandler];
                    }
                    count --;
                }
                if (count == 0) {
                    completionHandler(dict);
                }
        }];
    }
}

@end
