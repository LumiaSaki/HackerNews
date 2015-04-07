//
//  Story.h
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/7.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNStory : NSObject

@property (nonatomic, strong) NSString *author; //by
@property (nonatomic) NSUInteger descendants;   //descendants
@property (nonatomic) NSUInteger storyId;   //id
@property (nonatomic, strong) NSArray *comments;    //kids
@property (nonatomic) NSUInteger score; //score
@property (nonatomic, strong) NSDate *time; //time
@property (nonatomic, strong) NSString *title;  //title
@property (nonatomic, strong) NSString *type;   //type, 'story'
@property (nonatomic, strong) NSString *url;    //url

- (instancetype)initWithAuthor:(NSString *)author descendants:(NSUInteger)descendants storyId:(NSUInteger)storyId comments:(NSArray *)comments score:(NSUInteger)score time:(NSDate *)time title:(NSString *)title type:(NSString *)type url:(NSString *)url;

@end
