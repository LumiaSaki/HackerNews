//
//  HNStoryDetailViewController.m
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/9.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import "HNStoryDetailViewController.h"
#import "HNLoadController.h"

@interface HNStoryDetailViewController ()

@end

@implementation HNStoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    HNLoadController *loadController = [HNLoadController sharedLoadController];
    
    [loadController loadAllCommentsUnderStoryId:9346052 completionHandler:^(NSArray *comments) {
        for (HNComment *comment in comments) {
            NSLog(@"%lu, %@",(unsigned long)comment.commentId, comment.author);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
