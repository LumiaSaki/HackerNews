//
//  HNLocalDataController.m
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/13.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import "HNLocalDataController.h"

@implementation HNLocalDataController
+ (instancetype)sharedLocalDataController {
    static dispatch_once_t token;
    static HNLocalDataController *localDataController;
    
    dispatch_once(&token, ^{
        localDataController = [[HNLocalDataController alloc]init];
    });
    
    return localDataController;
}

- (void)createTableIfNeeded {
    FMDatabase *db = [self getDatabase];
    
    if ([db open]) {
        NSString *createCommentTableSql = @"create table if not exists comment_table (id integer primary key autoincrement not null, author text, comment_id integer unsigned not null, under_story_id integer, content_text text, time text, type text, depth integer)";
        [db executeUpdate:createCommentTableSql];
        
        [db close];
    }
}

//insert a story if not exist in database.
- (void)insertStory:(HNStory *)story {
    FMDatabase *db = [self getDatabase];
    
    if ([db open]) {
        NSString *insertStorySql = [NSString stringWithFormat:@"insert into story_table (author, descendants, story_id, score, time, title, type, url) values ('%@', %lu, %lu, %lu, '%@', '%@', '%@', '%@')", story.author, (unsigned long)story.descendants, (unsigned long)story.storyId, (unsigned long)story.score, story.time, story.title, story.type, story.url];
        
        [db executeUpdate:insertStorySql];
        
        [db close];
    }
}

//update a story which has existed in database.
- (void)updateStory:(HNStory *)story {
    FMDatabase *db = [self getDatabase];
    
    if ([db open]) {
        NSString *updateStorySql = [NSString stringWithFormat:@"update story_table set author = '%@', descendants = %lu, score = %lu, time = '%@', title = '%@', type = '%@', url = '%@' where story_id = %lu", story.author, (unsigned long)story.descendants, (unsigned long)story.score, story.time, story.title, story.type, story.url, (unsigned long)story.storyId];
        
        [db executeUpdate:updateStorySql];
        
        [db close];
    }
}

//get stories array which have existed in database.
- (NSArray *)getTopStoriesLimited:(NSUInteger)limited{
    FMDatabase *db = [self getDatabase];
    
    NSMutableArray *topStories = [NSMutableArray new];
    
    if ([db open]) {
        NSString *selectTopStoriesSql = [NSString stringWithFormat:@"select * from story_table order by id limit %lu", (unsigned long)limited];
        
        NSArray *topStoriesDicts = [self getDataForAttr:[self getStoryColumnArray] AndSql:selectTopStoriesSql];
        
        for (NSMutableDictionary *dict in topStoriesDicts) {
            HNStory *story = [[HNStory alloc] initWithAuthor:dict[@"author"] descendants:[dict[@"descendants"] unsignedIntegerValue] storyId:[dict[@"story_id"] unsignedIntegerValue] comments:nil score:[dict[@"score"] unsignedIntegerValue] time:dict[@"time"] title:dict[@"title"] type:dict[@"type"] url:dict[@"url"]];
            
            story.comments = [self getCommentsByStoryId:story.storyId];
            
            [topStories addObject:story];
        }
        [db close];
    }
    
    return topStories;
}

//insert a comment.
- (void)insertComment:(HNComment *)comment {
    FMDatabase *db = [self getDatabase];
    
    if ([db open]) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        
        NSString *insertCommentSql = [NSString stringWithFormat:@"insert into comment_table (author, comment_id, under_story_id, content_text, time, type, depth) values ('%@', %lu, %lu, '%@', '%@', '%@', %lu)", comment.author, (unsigned long)comment.commentId, (unsigned long)comment.underStoryId, comment.contentText, [dateFormatter stringFromDate:comment.time], comment.type, (unsigned long)comment.depth];
        
        [db executeUpdate:insertCommentSql];
        
        [db close];
    }
}

//get comments array(all).
- (NSMutableArray *)getCommentsByStoryId:(NSUInteger)storyId {
    FMDatabase *db = [self getDatabase];
    
    NSMutableArray *comments = [NSMutableArray new];
    
    if ([db open]) {
        NSString *selectCommentSql = [NSString stringWithFormat:@"select * from comment_table where under_story_id = %lu order by id", (unsigned long)storyId];
        
        NSArray *resultArray = [self getDataForAttr:[self getCommentColumnArray] AndSql:selectCommentSql];
        for (NSDictionary *commentDict in resultArray) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            
            [dateFormatter setDateFormat:@"yyyy/MM/dd"];
            
            HNComment *comment = [[HNComment alloc] initWithAuthor:commentDict[@"author"] commentId:[commentDict[@"comment_id"] unsignedIntegerValue] subComments:nil parent:0 contentText:commentDict[@"content_text"] time:[dateFormatter dateFromString:commentDict[@"time"]] type:commentDict[@"type"] depth:[commentDict[@"depth"] unsignedIntegerValue]];
            
            comment.underStoryId = [commentDict[@"under_story_id"] unsignedIntegerValue];
            
            [comments addObject:comment];
        }
        [db close];
    }
    
    return comments;
}

- (void)deleteCommentsByStoryId:(NSUInteger)storyId {
    FMDatabase *db = [self getDatabase];
    
    if ([db open]) {
        NSString *deleteCommentsUnderStoryIdSql = [NSString stringWithFormat:@"delete from comment_table where under_story_id = %lu", storyId];
        
        [db executeUpdate:deleteCommentsUnderStoryIdSql];
        
        [db close];
    }
}

#pragma mark - Private Methods

-(NSMutableArray *)getDataForAttr:(NSArray *)attr AndSql:(NSString *)sql
{
    NSMutableArray *allData=[[NSMutableArray alloc]init];
    
    FMDatabase *db = [self getDatabase];
    
    if ([db open]) {
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            for (int i = 0;i < attr.count; i++) {
                id object=[rs objectForColumnName: attr[i]];
                
                [dict setObject:object forKey:attr[i]];
            }
            [allData addObject:dict];
        }
        [db close];
    }
    return allData;
}

-(FMDatabase *)getDatabase
{
    NSString *docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbpath = [docsdir stringByAppendingPathComponent:@"HackerNews.sqlite"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbpath];
    return db;
}

- (NSArray *)getCommentByCommentId:(NSUInteger)commentId {
    FMDatabase *db = [self getDatabase];
    
    NSMutableArray *commentArray;
    if ([db open]) {
        NSString *selectCommentSql = [NSString stringWithFormat:@"select * from comment_table where comment_id = %lu", (unsigned long)commentId];
        
        commentArray = [[NSMutableArray alloc] initWithArray:[self getDataForAttr:[self getCommentColumnArray] AndSql:selectCommentSql]];
        
        [db close];
    }
    
    return commentArray;
}

- (NSArray *)getStoryColumnArray {
    return @[@"author", @"descendants", @"story_id", @"score", @"time", @"title", @"type", @"url"];
}

- (NSArray *)getCommentColumnArray {
    return @[@"author", @"comment_id", @"under_story_id", @"content_text", @"time", @"type", @"depth"];
}

@end
