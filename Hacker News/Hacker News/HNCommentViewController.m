//
//  HNCommentViewController.m
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/9.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import "HNCommentViewController.h"
#import "HNCommentCell.h"
#import "HNCommentStoryCell.h"
#import "HNStoryDetailViewController.h"
#import "HNUserInfoViewController.h"
#import "HNLocalDataController.h"

static NSString *COMMENT_CELL_IDENTIFIER = @"CommentCell";
static NSString *COMMENT_STORY_IDENTIFIER = @"CommentStoryCell";

@interface HNCommentViewController ()

@property (weak, nonatomic) IBOutlet UITableView *commentTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (nonatomic, strong) HNLoadController *loadController;
@property (nonatomic, strong) HNLocalDataController *localDataController;
@property (nonatomic, strong) NSArray *comments;


@end

@implementation HNCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _loadController = [HNLoadController sharedLoadController];
    _localDataController = [HNLocalDataController sharedLocalDataController];
    
    [_localDataController createTableIfNeeded];
    
    _commentTableView.rowHeight = UITableViewAutomaticDimension;
    _commentTableView.estimatedRowHeight = 189;
    
    [_commentTableView registerNib:[UINib nibWithNibName:@"HNCommentCell" bundle:nil] forCellReuseIdentifier:COMMENT_CELL_IDENTIFIER];
    [_commentTableView registerNib:[UINib nibWithNibName:@"HNCommentStoryCell" bundle:nil] forCellReuseIdentifier:COMMENT_STORY_IDENTIFIER];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storySourceButtonPressed) name:@"StorySourceButtonPressed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authorButtonPressed:) name:@"AuthorButtonInCommentPressed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authorButtonPressed:) name:@"StoryAuthorButtonPressed" object:nil];
    
    [_indicator startAnimating];
    
    NSArray *cachedComments = [_localDataController getCommentsByStoryId:_story.storyId];
    
    if ([cachedComments count] > 0) {
        
        NSMutableArray *commentArray = [[NSMutableArray alloc] initWithArray:cachedComments];
        [commentArray insertObject:_story atIndex:0];
        
        _comments = commentArray;
        
        [_indicator stopAnimating];
        
        [_commentTableView reloadData];
    }

    [_loadController loadAllCommentsUnderStoryId:_story.storyId completionHandler:^(NSMutableDictionary *commentsDict) {
        [self sortCommentsDict:commentsDict completionHandler:^(NSArray *sortedComments) {
            
            if ([cachedComments count] != [sortedComments count] - 1) {
                
                for (id object in sortedComments) {
                    if ([object isKindOfClass:[HNComment class]]) {
                        [_localDataController updateComment:object];
                    }
                }
                
                _comments = sortedComments;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_indicator stopAnimating];
                    
                    [_commentTableView reloadData];
                });
            }
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_comments count] != 0) {
        return [_comments count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_comments[indexPath.row] isKindOfClass:[HNStory class]]) {
        HNStory *story = _comments[indexPath.row];
        
        HNCommentStoryCell *storyCommentCell = [tableView dequeueReusableCellWithIdentifier:COMMENT_STORY_IDENTIFIER forIndexPath:indexPath];
        
        storyCommentCell.storyTitleLabel.text = story.title;
        [storyCommentCell.storyAuthorButton setTitle:[NSString stringWithFormat:@"%@",story.author] forState:UIControlStateNormal];
        
        return storyCommentCell;
        
    } else if ([_comments[indexPath.row] isKindOfClass:[HNComment class]]) {
        HNCommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:COMMENT_CELL_IDENTIFIER forIndexPath:indexPath];
        
        [commentCell.contentView removeConstraints:commentCell.commentLabel.constraints];
        
        HNComment *comment = _comments[indexPath.row];
        
        if (comment.contentText == nil || [comment.contentText isEqualToString:@"(null)"]) {
            [commentCell.authorButton setTitle:@"[deleted]" forState:UIControlStateNormal];
            commentCell.commentLabel.text = @"[deleted]";
        } else {
            [commentCell.authorButton setTitle:comment.author forState:UIControlStateNormal];
            commentCell.commentLabel.text = comment.contentText;
            
            NSUInteger padding = (comment.depth + 1) * 20;
            
            [commentCell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:commentCell.commentLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:commentCell.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
            
            [commentCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[authorLabel]-8-[commentLabel]-8-|" options:0 metrics:nil views:@{ @"commentLabel": commentCell.commentLabel , @"authorLabel" : commentCell.authorButton}]];
            [commentCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%lu-[commentLabel]-2-|",(unsigned long)padding] options:0 metrics:nil views:@{ @"commentLabel": commentCell.commentLabel}]];
            
            [commentCell.contentView setNeedsLayout];
            [commentCell.contentView layoutIfNeeded];
        }
        return commentCell;
    } else {
        return nil;
    }
}

- (void)sortCommentsDict:(NSMutableDictionary *)commentsDict completionHandler:(void(^)(NSArray *sortedComments))completionHandler{
    NSArray *topComments = _story.comments;
        
    __block NSMutableArray *array = [NSMutableArray new];
        
    [self saveSortedCommentByCommentArray:topComments toArray:array commentDict:commentsDict];
        
    [array insertObject:_story atIndex:0];
        
    completionHandler(array);
}

- (void)saveSortedCommentByCommentArray:(NSArray *)commentArray toArray:(NSMutableArray *)array commentDict:(NSMutableDictionary *)commentsDict {
    
    for (NSNumber *commentId in commentArray) {
        HNComment *comment = commentsDict[[NSString stringWithFormat:@"%lu", (unsigned long)[commentId unsignedIntegerValue]]];
        
        [array addObject:comment];
        
        if ([comment.subComments count] != 0) {
            [self saveSortedCommentByCommentArray:comment.subComments toArray:array commentDict:commentsDict];
        }
    }
}

- (void)getStoryById:(NSUInteger)storyId completionHandler:(void(^)(HNStory *story))completionHandler {
    [_loadController loadStoryById:storyId completionHandler:^(HNStory *story) {
        completionHandler(story);
    }];
}

- (void)storySourceButtonPressed {
    HNStoryDetailViewController *storyDetailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"StoryDetailViewController"];
    
    storyDetailVC.story = _story;
    
    [self.navigationController pushViewController:storyDetailVC animated:YES];
}

- (void)authorButtonPressed:(NSNotification *)notification {
    HNUserInfoViewController *userInfoVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    
    userInfoVC.userId = notification.userInfo[@"userId"];
    
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
