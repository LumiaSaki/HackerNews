//
//  HNUserInfoViewController.m
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/10.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import "HNUserInfoViewController.h"
#import "HNLoadController.h"
#import "HNTopStoryTableViewCell.h"
#import "HNCommentCell.h"
#import "HNCommentViewController.h"
#import <Masonry.h>

static NSString *SUBMITTED_STORY_CELL_IDENTIFIER = @"SubmittedStoryCell";
static NSString *SUBMITTED_COMMENT_CELL_IDENTIFIER = @"SubmittedCommentCell";

@interface HNUserInfoViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UITableView *submittedTableView;

@property (nonatomic, strong) HNLoadController *loadController;
@property (nonatomic, strong) NSMutableArray *submittedStoriesAndComments;
@property (nonatomic) NSUInteger currentItemIndex;
@property (nonatomic, strong) HNUser *user;


@end

@implementation HNUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _currentItemIndex = 0;
    
    _userIdLabel.text = _userId;
    
    _loadController = [HNLoadController sharedLoadController];
    
    _submittedStoriesAndComments = [NSMutableArray new];
    
    [_submittedTableView registerNib:[UINib nibWithNibName:@"HNTopStoryTableViewCell" bundle:nil] forCellReuseIdentifier:SUBMITTED_STORY_CELL_IDENTIFIER];
    [_submittedTableView registerNib:[UINib nibWithNibName:@"HNCommentCell" bundle:nil] forCellReuseIdentifier:SUBMITTED_COMMENT_CELL_IDENTIFIER];
    
    _submittedTableView.rowHeight = UITableViewAutomaticDimension;
    _submittedTableView.estimatedRowHeight = 189;
    
    [_indicator startAnimating];
    
    [_loadController loadUserById:_userId completionHandler:^(HNUser *user) {
        _user = user;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([user.about isEqualToString:@""] || user.about == nil) {
                _aboutLabel.text = @"He/She is so lazy, write nothing...";
            } else {
                _aboutLabel.text = user.about;
            }
            
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            
            [dateFormatter setDateFormat:@"yyyy/MM/dd"];
            
            _createdLabel.text = [NSString stringWithFormat:@"create:%@",[dateFormatter stringFromDate:user.createDate]];
            _karmaLabel.text = [NSString stringWithFormat:@"karma: %lu", (unsigned long)user.karma];
            _delayLabel.text = [NSString stringWithFormat:@"delay: %lu", (unsigned long)user.delay];
            
            [self loadMore:5 submittedArray:user.submitted];
            
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMore:(NSUInteger)moreCount submittedArray:(NSArray *)submittedArray {
    if (_loadController == nil) {
        _loadController = [HNLoadController sharedLoadController];
    }
    
    if (submittedArray != nil) {
        [_loadController loadStoryOrCommentByItemIdArray:submittedArray fromIndex:_currentItemIndex toIndex:_currentItemIndex + moreCount - 1 completionHandler:^(NSMutableArray *itemArray) {
            if (itemArray != nil) {
                [_submittedStoriesAndComments addObjectsFromArray:itemArray];
                
                _currentItemIndex += [itemArray count];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_submittedTableView reloadData];
                    
                    [_indicator stopAnimating];
                });
            }
        }];

    } else {
        [_indicator stopAnimating];
    }
    
    if (_currentItemIndex == [submittedArray count]) {
        [_indicator stopAnimating];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_submittedStoriesAndComments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [_submittedStoriesAndComments count] - 1) {
        [_indicator startAnimating];
        
        [self loadMore:5 submittedArray:_user.submitted];
    }
    
    if ([_submittedStoriesAndComments[indexPath.row] isKindOfClass:[HNStory class]]) {
        HNTopStoryTableViewCell *submittedStoryCell = [tableView dequeueReusableCellWithIdentifier:SUBMITTED_STORY_CELL_IDENTIFIER];
    
        HNStory *story = _submittedStoriesAndComments[indexPath.row];
        
        if (story.title == nil) {
            submittedStoryCell.authorLabel.text = @"[deleted]";
            submittedStoryCell.titleLabel.text = @"[deleted]";
            submittedStoryCell.clickCountLabel.text = @"";
            submittedStoryCell.commentCountLabel.text = @"";
            
        } else {
            submittedStoryCell.authorLabel.text = story.author;
            submittedStoryCell.titleLabel.text = story.title;
            submittedStoryCell.clickCountLabel.text = [NSString stringWithFormat:@"clicked:%lu", (unsigned long)story.score];
            submittedStoryCell.commentCountLabel.text = [NSString stringWithFormat:@"comments:%lu", (unsigned long)[story.comments count]];
        }
        
        return submittedStoryCell;
        
    } else if ([_submittedStoriesAndComments[indexPath.row] isKindOfClass:[HNComment class]]) {
        HNCommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:SUBMITTED_COMMENT_CELL_IDENTIFIER];
        
        HNComment *comment = _submittedStoriesAndComments[indexPath.row];
        
        if (comment.contentText == nil) {
            [commentCell.authorButton setTitle:@"[deleted]" forState:UIControlStateNormal];
            commentCell.commentLabel.text = @"[deleted]";
        } else {
            [commentCell.authorButton setTitle:comment.author forState:UIControlStateNormal];
            commentCell.authorButton.userInteractionEnabled = NO;
            
            commentCell.commentLabel.text = comment.contentText;
        }
        
        [commentCell.commentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(commentCell.contentView).with.offset(15);
        }];
        
        return commentCell;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_submittedStoriesAndComments[indexPath.row] isKindOfClass:[HNStory class]]) {
        HNStory *story = _submittedStoriesAndComments[indexPath.row];
        
        HNCommentViewController *commentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentViewController"];
        
        commentVC.story = story;
    
        [self.navigationController pushViewController:commentVC animated:YES];
    }
}
@end
