//
//  HNStoryDetailViewController.m
//  Hacker News
//
//  Created by Lumia_Saki on 15/4/9.
//  Copyright (c) 2015年 Tianren.Zhu. All rights reserved.
//

#import "HNStoryDetailViewController.h"
#import "HNLoadController.h"
#import "HNStoryDetailLoadIndicatorBarButtonItem.h"

@interface HNStoryDetailViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *storyDetailWebView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) HNStoryDetailLoadIndicatorBarButtonItem *indicatorButton;
@property (nonatomic, strong) UIBarButtonItem *shareBarButton;

@end

@implementation HNStoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSURL *url = [NSURL URLWithString:_story.url];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [_storyDetailWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    _shareBarButton = nil;
    
    _indicatorButton = [HNStoryDetailLoadIndicatorBarButtonItem new];
    
    self.navigationItem.rightBarButtonItem = _indicatorButton;
    
    [_indicatorButton.indicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_indicatorButton.indicator stopAnimating];
    
    _indicatorButton = nil;
    
    _shareBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
    
    self.navigationItem.rightBarButtonItem = _shareBarButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)share {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[_story.title, _story.url] applicationActivities:nil];
    
    activityVC.excludedActivityTypes = @[UIActivityTypeAirDrop];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}
@end
