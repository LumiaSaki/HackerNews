//
//  ViewController.m
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/7.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import "HNTopStoryViewController.h"
#import "HNLoadController.h"
#import "HNTopStoryTableViewCell.h"
#import "HNCommentViewController.h"

static NSString *TOP_STORY_CELL_IDENTIFIER = @"TopStory";

@interface HNTopStoryViewController ()

@property (weak, nonatomic) IBOutlet UITableView *topStoriesTableView;

@property (nonatomic, strong) HNLoadController *loadController;
@property (nonatomic, strong) NSMutableArray *topStories;
@property (nonatomic) NSUInteger currentTopStoryIndex;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation HNTopStoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _topStories = [NSMutableArray new];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [_topStoriesTableView addSubview:_refreshControl];
    
    [_topStoriesTableView registerNib:[UINib nibWithNibName:@"HNTopStoryTableViewCell" bundle:nil] forCellReuseIdentifier:TOP_STORY_CELL_IDENTIFIER];
    
    _currentTopStoryIndex = 0;
    
    [_refreshControl beginRefreshing];
    
    [self refreshData];
//    _loadController = [HNLoadController sharedLoadController];
    
//    [self refreshData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMore:(NSUInteger)moreStoriesCount {
    //从网络读取
    if (_loadController == nil) {
        _loadController = [HNLoadController sharedLoadController];
    }
    [_loadController loadTopStoriesFromIndex:_currentTopStoryIndex toIndex:_currentTopStoryIndex + moreStoriesCount - 1 completionHandler:^(NSArray *topStories) {
        [_topStories addObjectsFromArray:topStories];
        
        _currentTopStoryIndex += moreStoriesCount;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_topStoriesTableView reloadData];
        });
    }];
    
    //从本地读取
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_topStories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HNTopStoryTableViewCell *topStoryCell = [tableView dequeueReusableCellWithIdentifier:TOP_STORY_CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (indexPath.row == [_topStories count] - 1) {
        [self loadMore:10];
    }
    
    HNStory *story = _topStories[indexPath.row];
    
    if (story.title == nil) {
        topStoryCell.titleLabel.text = @"[deleted]";
        topStoryCell.authorLabel.text = @"[deleted]";
        topStoryCell.clickCountLabel.text = @"";
        topStoryCell.commentCountLabel.text = @"";
    } else {
        topStoryCell.titleLabel.text = story.title;
        topStoryCell.authorLabel.text = story.author;
        topStoryCell.clickCountLabel.text = [NSString stringWithFormat:@"clicked:%lu", (unsigned long)story.score];
        topStoryCell.commentCountLabel.text = [NSString stringWithFormat:@"comments:%lu", (unsigned long)[story.comments count]];
    }
    
    return topStoryCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HNStory *story = _topStories[indexPath.row];
    
    HNCommentViewController *commentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentViewController"];
    
    commentVC.story = story;
//    commentVC.storyId = story.storyId;
    
    [self.navigationController pushViewController:commentVC animated:YES];
}

- (void)refreshData {
    [self refreshDataByCount:10];
}

- (void)refreshDataByCount:(NSUInteger)storiesCount {
    _currentTopStoryIndex = 0;
    
    if (_loadController == nil) {
        _loadController = [HNLoadController sharedLoadController];
    }
    [_loadController loadTopStoriesFromIndex:_currentTopStoryIndex toIndex:storiesCount - 1 completionHandler:^(NSArray *topStories) {
        _topStories = [[NSMutableArray alloc] initWithArray:topStories];
        
        _currentTopStoryIndex = storiesCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_topStoriesTableView reloadData];
            
            [_refreshControl endRefreshing];
        });
    }];
}



@end
