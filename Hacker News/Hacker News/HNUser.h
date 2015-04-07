//
//  HNComment.h
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/7.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNUser : NSObject

@property (nonatomic, strong) NSString *about;  //about
@property (nonatomic, strong) NSDate *createDate;   //time
@property (nonatomic) NSUInteger delay; //delay
@property (nonatomic, strong) NSString *userId; //id
@property (nonatomic) NSUInteger karma; //karma
@property (nonatomic, strong) NSArray *submitted;   //submitted

- (instancetype)initWithAbout:(NSString *)about createDate:(NSDate *)createDate delay:(NSUInteger)delay userId:(NSString *)userId karma:(NSUInteger)karma submitted:(NSArray *)submitted;

@end
