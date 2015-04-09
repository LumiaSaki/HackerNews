//
//  HNCommentViewController.m
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/9.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import "HNCommentViewController.h"
#import "HNCommentCell.h"

static NSString *COMMENT_CELL_IDENTIFIER = @"CommentCell";
@interface HNCommentViewController ()

@property (weak, nonatomic) IBOutlet UITableView *commentTableView;

@property (nonatomic, strong) HNLoadController *loadController;
@property (nonatomic, strong) HNStory *story;
@property (nonatomic, strong) NSArray *comments;

@end

@implementation HNCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _loadController = [HNLoadController sharedLoadController];

    _commentTableView.rowHeight = UITableViewAutomaticDimension;
    _commentTableView.estimatedRowHeight = 189;
    
    [_commentTableView registerNib:[UINib nibWithNibName:@"HNCommentCell" bundle:nil] forCellReuseIdentifier:COMMENT_CELL_IDENTIFIER];
    
    UIActivityIndicatorView *indivitorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [_commentTableView addSubview:indivitorView];
    
    indivitorView.center = self.view.center;
    
    [indivitorView startAnimating];

    [_loadController loadAllCommentsUnderStoryId:_storyId completionHandler:^(NSArray *comments) {
        _comments = comments;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [indivitorView stopAnimating];
            
            [_commentTableView reloadData];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HNCommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:COMMENT_CELL_IDENTIFIER forIndexPath:indexPath];
    
    if (commentCell == nil) {
        commentCell = [[HNCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:COMMENT_CELL_IDENTIFIER];
    }
    
    [commentCell.contentView removeConstraints:commentCell.commentLabel.constraints];
    
    HNComment *comment = _comments[indexPath.row];
    
    if (comment.contentText == nil) {
        commentCell.authorLabel.text = @"";
        commentCell.commentLabel.text = @"Comment has been deleted";
    } else {
        commentCell.authorLabel.text = comment.author;
        commentCell.commentLabel.text = comment.contentText;
        
        NSUInteger padding = (comment.depth + 1)* 20;
        
        [commentCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[authorLabel]-2-[commentLabel]-5-|" options:0 metrics:nil views:@{ @"commentLabel": commentCell.commentLabel , @"authorLabel" : commentCell.authorLabel}]];
        [commentCell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%lu-[commentLabel]-20-|",(unsigned long)padding] options:0 metrics:nil views:@{ @"commentLabel": commentCell.commentLabel}]];

    }
    return commentCell;
}

//- (NSArray *)sortComments:(NSArray *)comments {
//    //扫
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
