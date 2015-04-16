//
//  HNLocalDataController.m
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/13.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import "HNLocalDataController.h"

@implementation HNLocalDataController

# pragma mark - Public Methods
/**
 *  单例方法
 *
 *  @return localDataController实例
 */
+ (instancetype)sharedLocalDataController {
    static dispatch_once_t token;
    static HNLocalDataController *localDataController;
    
    dispatch_once(&token, ^{
        localDataController = [[HNLocalDataController alloc]init];
    });
    
    return localDataController;
}

/**
 *  如果需要的话，在数据库中创建用于缓存数据的表
 */
- (void)createTableIfNeeded {
    FMDatabase *db = [self getDatabase];
    
    if ([db open]) {
        NSString *createCommentTableSql = @"create table if not exists comment_table (id integer primary key autoincrement not null, author text, comment_id integer unsigned not null, under_story_id integer, content_text text, time text, type text, depth integer)";
        [db executeUpdate:createCommentTableSql];
        
        [db close];
    }
}

/**
 *  在表中插入一条comment
 *
 *  @param comment 要插入的HNComment
 */
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

/**
 *  从数据库中得到该story id下所有comments
 *
 *  @param storyId 要请求的story id
 *
 *  @return 排好序的该story id下所有的HNComment的数组
 */
- (NSMutableArray *)getCommentsByStoryId:(NSUInteger)storyId {
    FMDatabase *db = [self getDatabase];
    
    NSMutableArray *comments = [NSMutableArray new];
    
    if ([db open]) {
        NSString *selectCommentSql = [NSString stringWithFormat:@"select * from comment_table where under_story_id = %lu order by id", (unsigned long)storyId];
        
        NSArray *resultArray = [self getDataByAttr:[self getCommentColumnArray] AndSql:selectCommentSql];
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

/**
 *  删除特定story id下所有的comment，用于更新comment数据
 *
 *  @param storyId 要删除的story id
 */
- (void)deleteCommentsByStoryId:(NSUInteger)storyId {
    FMDatabase *db = [self getDatabase];
    
    if ([db open]) {
        NSString *deleteCommentsUnderStoryIdSql = [NSString stringWithFormat:@"delete from comment_table where under_story_id = %lu", storyId];
        
        [db executeUpdate:deleteCommentsUnderStoryIdSql];
        
        [db close];
    }
}

#pragma mark - Private Methods

/**
 *  用于数据库select操作的通用方法，对于任何结构的表均适用
 *
 *  @param attr 要执行select方法的表的字段数组
 *  @param sql  要执行的sql语句
 *
 *  @return 包含所有查询到的值的数组，该数组中每一个的值为包含一个实体的dict，可根据该dict还原出所需的model
 */
-(NSMutableArray *)getDataByAttr:(NSArray *)attr AndSql:(NSString *)sql
{
    NSMutableArray *allData = [NSMutableArray new];
    
    FMDatabase *db = [self getDatabase];
    
    if ([db open]) {
        FMResultSet * resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            NSMutableDictionary *objectInfoDict = [NSMutableDictionary new];
            for (int i = 0;i < attr.count; i++) {
                id object = [resultSet objectForColumnName: attr[i]];
                if (object != nil) {
                    [objectInfoDict setObject:object forKey:attr[i]];
                }
            }
            [allData addObject:objectInfoDict];
        }
        [db close];
    }
    return allData;
}

/**
 *  建立数据库，并返回数据库实例
 *
 *  @return FMDB数据库实例
 */
-(FMDatabase *)getDatabase
{
    NSString *docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbpath = [docsdir stringByAppendingPathComponent:@"HackerNews.sqlite"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbpath];
    
    return db;
}

/**
 *  story表的字段数组
 *
 *  @return 字段数组
 */
- (NSArray *)getStoryColumnArray {
    return @[@"author", @"descendants", @"story_id", @"score", @"time", @"title", @"type", @"url"];
}

/**
 *  comment表的字段数组
 *
 *  @return 字段数组
 */
- (NSArray *)getCommentColumnArray {
    return @[@"author", @"comment_id", @"under_story_id", @"content_text", @"time", @"type", @"depth"];
}

#pragma mark - Cache story methods, not implementation yet

- (void)insertStory:(HNStory *)story {
    FMDatabase *db = [self getDatabase];
    
    if ([db open]) {
        NSString *insertStorySql = [NSString stringWithFormat:@"insert into story_table (author, descendants, story_id, score, time, title, type, url) values ('%@', %lu, %lu, %lu, '%@', '%@', '%@', '%@')", story.author, (unsigned long)story.descendants, (unsigned long)story.storyId, (unsigned long)story.score, story.time, story.title, story.type, story.url];
        
        [db executeUpdate:insertStorySql];
        
        [db close];
    }
}

- (void)updateStory:(HNStory *)story {
    FMDatabase *db = [self getDatabase];
    
    if ([db open]) {
        NSString *updateStorySql = [NSString stringWithFormat:@"update story_table set author = '%@', descendants = %lu, score = %lu, time = '%@', title = '%@', type = '%@', url = '%@' where story_id = %lu", story.author, (unsigned long)story.descendants, (unsigned long)story.score, story.time, story.title, story.type, story.url, (unsigned long)story.storyId];
        
        [db executeUpdate:updateStorySql];
        
        [db close];
    }
}

- (NSArray *)getTopStoriesLimited:(NSUInteger)limited{
    FMDatabase *db = [self getDatabase];
    
    NSMutableArray *topStories = [NSMutableArray new];
    
    if ([db open]) {
        NSString *selectTopStoriesSql = [NSString stringWithFormat:@"select * from story_table order by id limit %lu", (unsigned long)limited];
        
        NSArray *topStoriesDicts = [self getDataByAttr:[self getStoryColumnArray] AndSql:selectTopStoriesSql];
        
        for (NSMutableDictionary *dict in topStoriesDicts) {
            HNStory *story = [[HNStory alloc] initWithAuthor:dict[@"author"] descendants:[dict[@"descendants"] unsignedIntegerValue] storyId:[dict[@"story_id"] unsignedIntegerValue] comments:nil score:[dict[@"score"] unsignedIntegerValue] time:dict[@"time"] title:dict[@"title"] type:dict[@"type"] url:dict[@"url"]];
            
            story.comments = [self getCommentsByStoryId:story.storyId];
            
            [topStories addObject:story];
        }
        [db close];
    }
    
    return topStories;
}

# pragma mark - Deprecated Methods

/**
 *  通过select操作得到一条comment，
 *
 *  @param commentId 要查询的comment id
 *
 *  @return 如果数据库中有符合的数据，则返回数组，数组可能为空，或有一个值，或多个值
 */
- (NSArray *)getCommentByCommentId:(NSUInteger)commentId {
    FMDatabase *db = [self getDatabase];
    
    NSMutableArray *commentArray;
    if ([db open]) {
        NSString *selectCommentSql = [NSString stringWithFormat:@"select * from comment_table where comment_id = %lu", (unsigned long)commentId];
        
        commentArray = [[NSMutableArray alloc] initWithArray:[self getDataByAttr:[self getCommentColumnArray] AndSql:selectCommentSql]];
        
        [db close];
    }
    
    return commentArray;
}
@end
