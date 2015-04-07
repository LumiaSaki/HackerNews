//
//  HNComment.h
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/7.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNComment : NSObject

@property (nonatomic, strong) NSString *author; //by
@property (nonatomic) NSUInteger commentId; //id
@property (nonatomic, strong) NSArray *subComments; //kids
@property (nonatomic) NSUInteger parent;    //parent, parent comment or relative story(for top comment case)
@property (nonatomic, strong) NSString *contentText;    //text, HTML
@property (nonatomic, strong) NSDate *time; //time
@property (nonatomic, strong) NSString *type;   //type, 'comment'

@end
