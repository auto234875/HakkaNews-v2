//
//  topStoriesViewController.m
//  YNews
//
//  Created by John Smith on 12/24/13.
//  Copyright (c) 2013 John Smith. All rights reserved.
//

#import "topStoriesViewController.h"
#import "CommentsViewController.h"
#import <Colours/Colours.h>
#import "postCell.h"
#import "LoginVC.h"
#import "FBShimmeringLayer.h"
#import "FoldingWebView.h"
#import <pop/POP.h>
#import "HNManager.h"
#import <MCFireworksButton.h>
#import "FoldingTableView.h"
@interface topStoriesViewController () <UIGestureRecognizerDelegate,UIScrollViewDelegate,UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,FoldingViewDelegate>
@property (nonatomic, strong) NSMutableArray *readPost;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong)NSIndexPath *selectedIndexPath;
@property(nonatomic)BOOL userIsLoggedIn;
@property (nonatomic, strong)NSIndexPath *upvoteIndexPath;
@property(strong, nonatomic)UIActionSheet *as;
@property(strong,nonatomic)NSMutableArray *upvote;
@property(strong,nonatomic)FBShimmeringLayer *loadingLayer;
@property(strong,nonatomic)UITableView *tableView;
@property(nonatomic,strong)UIButton *menuButton;
@property(nonatomic,strong)UIImageView *menuImage;
@property(nonatomic,strong)UIButton *topButton;
@property(nonatomic,strong)UIButton *nButton;
@property(nonatomic,strong)UIButton *askButton;

@end
@implementation topStoriesViewController
#define postTitlePadding 15
#define tableViewTag 23
-(UITableView*)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.tag=tableViewTag;
       [self.view addSubview:_tableView];
    }
    return _tableView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HNPost *post=[self.currentPosts objectAtIndex:indexPath.row];
    if ([self.readPost containsObject:post.PostId]) {
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
        CGFloat cellWidth= self.tableView.frame.size.width-30;
        CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
        CGSize textSize = [post.Title boundingRectWithSize:boundingSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName : textFont }
                                                   context:nil].size;
        return textSize.height+44+postTitlePadding*2;
    }
    else{
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
        CGFloat cellWidth= self.tableView.frame.size.width-30;
        CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
        CGSize textSize = [post.Title boundingRectWithSize:boundingSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName : textFont }
                                                   context:nil].size;
        return textSize.height+44+postTitlePadding*2;
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
-(NSMutableArray*)readPost{
    if (!_readPost) {
        _readPost = [[NSMutableArray alloc] init];
    }
    return _readPost;
}
-(NSMutableArray*)upvote{
    if (!_upvote) {
        _upvote = [[NSMutableArray alloc] init];
    }
    return _upvote;
}
- (void)saveTheListOfReadPost {
    [[NSUserDefaults standardUserDefaults] setObject:self.readPost forKey:@"listOfReadPosts"];
}
- (void)saveTheListOfUpvote {
    [[NSUserDefaults standardUserDefaults] setObject:self.upvote forKey:@"listOfUpvote"];
}
- (void)retrieveListofReadPost {
    self.readPost= [[[NSUserDefaults standardUserDefaults] objectForKey:@"listOfReadPosts"] mutableCopy];
}
- (void)retrieveListofUpvote {
    self.upvote= [[[NSUserDefaults standardUserDefaults] objectForKey:@"listOfUpvote"] mutableCopy];
}
- (void)initialUserSetup {
    if ([[HNManager sharedManager]userIsLoggedIn]) {
        self.userIsLoggedIn=YES;
    }
    else{
        self.userIsLoggedIn=NO;

    }
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initialUserSetup) name:@"userIsLoggedIn" object:nil];
    [self initialUserSetup];
    [self retrieveListofReadPost];
    [self retrieveListofUpvote];
    self.postType=@"Top";
    [self getStories];
    self.tableView.backgroundColor=[UIColor snowColor];
    self.tableView.delaysContentTouches=NO;
    self.limitReached=NO;
    self.tableView.tag=1;
    self.loadingLayer=[FBShimmeringLayer layer];
    self.loadingLayer.frame=CGRectMake(0,0, self.view.bounds.size.width, 5);
    UIButton *loginButton=[[UIButton alloc] initWithFrame:CGRectMake(15, 15, 44, 44)];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"action" ] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(showLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    CALayer *layer=[CALayer layer];
    layer.frame=self.loadingLayer.bounds;
    layer.backgroundColor=[UIColor redColor].CGColor;
    self.loadingLayer.contentLayer=layer;
    self.loadingLayer.shimmering=YES;
    [self.view.layer addSublayer:self.loadingLayer];
}
-(void)showLogin{
    LoginVC *login=[[LoginVC alloc] init];
    [self presentViewController:login animated:YES completion:nil];
}
-(void)getBestStories{
    self.postType=@"Best";
    [self getStories];
}
-(void)getAskStories{
    self.postType=@"Ask";
    [self getStories];
}
-(void)getTopStories{
    self.postType=@"Top";
    [self getStories];
}
-(void)getNewStories{
    self.postType=@"New";
    [self getStories];
}
-(void)setupLoggedIn{
    
    self.userIsLoggedIn=YES;
    [self.tableView reloadData];
}
-(void)setupNotLoggedIn{
    
    self.userIsLoggedIn=NO;
    [self.tableView reloadData];
}
-(void)turnOffShimmeringLayer{
    self.loadingLayer.shimmering=NO;
    self.loadingLayer.opacity=0.0;
}
-(void)turnOnShimmeringLayer{
    self.loadingLayer.shimmering=YES;
    self.loadingLayer.opacity=0.8;
}
- (void)getStories {
    [self turnOnShimmeringLayer];
    if ([self.postType isEqualToString:@"Top"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeTop completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                [self.tableView reloadData];
                [self turnOffShimmeringLayer];
                }
            else{
                //stop loading animation
            }
        }];
    }
    else if ([self.postType isEqualToString:@"New"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeNew completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                [self.tableView reloadData];
                [self turnOffShimmeringLayer];
            }
            else{
                //stop loading animation
            }
        }];
    }
    else if ([self.postType isEqualToString:@"Best"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeBest completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                [self.tableView reloadData];
                [self turnOffShimmeringLayer];
            }
            else{
                //stop loading animation
            }
        }];
    }
    else if ([self.postType isEqualToString:@"Ask"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeAsk completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                [self.tableView reloadData];
                [self turnOffShimmeringLayer];
            }
            else{
                //stop loading animation
            }
        }];
    }
    else if ([self.postType isEqualToString:@"Jobs"]) {
        [[HNManager sharedManager] loadPostsWithFilter:PostFilterTypeJobs completion:^(NSArray *posts, NSString *urlAddition){
            if (posts) {
                self.currentPosts = [NSMutableArray arrayWithArray:posts];
                [self.tableView reloadData];
                [self turnOffShimmeringLayer];
            }
            else{
                //stop loading animation
            }
        }];
    }
    [self scrollToTopOfTableView];
}
- (void)scrollToTopOfTableView {
    self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self.currentPosts count];
}
- (void)setupCellSelectedBackgroundColor:(postCell *)cell
{
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    [selectedBackgroundView setBackgroundColor:[UIColor whiteColor]]; // set color here
    [cell setSelectedBackgroundView:selectedBackgroundView];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    HNPost *post=[self.currentPosts objectAtIndex:indexPath.row];

    [tableView registerClass:[postCell class] forCellReuseIdentifier:CellIdentifier];
    postCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
     cell=[[postCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
     }
    [self configureCell:cell forRowAtIndexPath:indexPath];
    [self setupCellSelectedBackgroundColor:cell];
    cell.postTitle.highlightedTextColor = [UIColor turquoiseColor];
    cell.contentView.backgroundColor=[UIColor snowColor];
    if ([self.readPost containsObject:post.PostId]) {
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
        CGFloat cellWidth= self.tableView.frame.size.width-postTitlePadding*2;
        CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
        CGSize textSize = [post.Title boundingRectWithSize:boundingSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName : textFont }
                                                   context:nil].size;
        cell.postTitle.frame=CGRectMake(15, 15, textSize.width, textSize.height);
    }
    else{
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
        CGFloat cellWidth= self.tableView.frame.size.width-postTitlePadding*2;
        CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
        CGSize textSize = [post.Title boundingRectWithSize:boundingSize
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{ NSFontAttributeName : textFont }
                                                   context:nil].size;
        cell.postTitle.frame=CGRectMake(15, 15, textSize.width, textSize.height);
    }
    cell.actionButton.tag=indexPath.row;
    cell.postDetail.tag=indexPath.row;
    cell.actionButton.frame=CGRectMake(5, cell.postTitle.frame.origin.y+cell.postTitle.frame.size.height+postTitlePadding, 44, 44);
    cell.likeButton.frame=CGRectMake(cell.actionButton.frame.origin.x+cell.actionButton.frame.size.width,cell.actionButton.frame.origin.y , 44, 44);
    [cell.actionButton addTarget:self action:@selector(actionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    cell.postDetail.frame=CGRectMake((self.tableView.bounds.size.width/2)-15, cell.likeButton.frame.origin.y, (self.tableView.bounds.size.width/2), 44);
    [cell.postDetail addTarget:self action:@selector(postDetailButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.postDetail setTitle:[NSString stringWithFormat:@"%i points  %i comments", post.Points, post.CommentCount]
                     forState:UIControlStateNormal];
    if (self.userIsLoggedIn) {
        if (post.Type == PostTypeDefault || post.Type==PostTypeAskHN) {

    if ([self.upvote containsObject:post.PostId]) {
        [cell.likeButton setImage:[UIImage imageNamed:@"Like-Blue"] forState:UIControlStateNormal];
        }
    else{
    [cell.likeButton setImage:[UIImage imageNamed:@"Like"] forState:UIControlStateNormal];
    }
    cell.likeButton.tag=indexPath.row;
    [cell.likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return cell;
}
-(void)postDetailButtonPressed:(UIButton*)sender{
    HNPost *post=[self.currentPosts objectAtIndex:sender.tag];
    if (post.Type==PostTypeDefault) {
        //if there is no comment, we don't segue
        if (post.CommentCount==0){
            //show animation
            return;
        }
        else {
            //we add the post to the read post list and segue to comment
            [self.readPost addObject:post.PostId];
            [self showComment:post];
            
        }
        
    }
    else if (post.Type == PostTypeAskHN){
        //we always show the comment because it's askHN
        //askHN always have at least 1 comment
        [self.readPost addObject:post.PostId];
        [self showComment:post];
        
    }
    //Job Post, check to see if it's a self post or webpage by loading the first comment and checking the string
    else if (post.Type == PostTypeJobs){[[HNManager sharedManager] loadCommentsFromPost:post completion:^(NSArray *comments) {
        HNComment *firstComment = [comments firstObject];
        if (![firstComment.Text isEqualToString:@""]) {
            if (self.comments) {
                self.comments = [comments mutableCopy];}
            else{
                self.comments = [NSMutableArray arrayWithArray:comments];
            }
            [self.readPost addObject:post.PostId];
            [self showComment:post];
            
        }
        else {
            [self.readPost addObject:post.PostId];
            [self showStoryOfPost:post];
            
        }
        
    }];}
}
-(void)likeButtonPressed:(MCFireworksButton*)sender{
    HNPost *post=[self.currentPosts objectAtIndex:sender.tag];
    if ([self.upvote containsObject:post.PostId]) {
        return;
    }
    else{
        [[HNManager sharedManager] voteOnPostOrComment:post direction:VoteDirectionUp completion:^(BOOL success) {
        if (success){
            [self.upvote addObject:post.PostId];
            [self saveTheListOfUpvote];
            [sender popOutsideWithDuration:0.5];
            [sender setImage:[UIImage imageNamed:@"Like-Blue"] forState:UIControlStateNormal];
            [sender animate];
        }
        else {
            //can't upvote
            //stop loading animation
        }
    }];
    }
}
-(void)actionButtonPressed{
    NSLog(@"action");
}
- (void)configureCell:(postCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    HNPost *post=[self.currentPosts objectAtIndex:indexPath.row];
    //check if the post exist in readPost array and set the postTitle font accordingly
    if ([self.readPost containsObject:post.PostId]) {
        cell.postTitle.font= [UIFont fontWithName:@"AvenirNext-Regular" size:14];
        cell.postTitle.textColor=[UIColor lightGrayColor];
    }
    else{
        cell.postTitle.font= [UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
        cell.postTitle.textColor=[UIColor blackColor];
    }
    cell.postTitle.text=post.Title;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //get the indexpath of the selected cell so we can perform segue
    self.selectedIndexPath = indexPath;
    //retrieve the corresponding post
    HNPost *post=[self.currentPosts objectAtIndex:indexPath.row];
    //add it to the the list of read posts
    [self.readPost addObject:post.PostId];
    //if the post is default, we go to the webpage
    if (post.Type == PostTypeDefault){
        [self showStoryOfPost:post];

    }
    //if the post is ask, we show the comment because AskHN is always self-post on HN
    else if (post.Type == PostTypeAskHN){
        [self showComment:post];

        }
    //if it is a job post, we have to load the comment and check to see if it is self post or from a webpage
    else if (post.Type== PostTypeJobs){
        [[HNManager sharedManager] loadCommentsFromPost:post completion:^(NSArray *comments) {
            //getting the first comment and checking if the string is empty
            //the string is NEVER nil
            HNComment *firstComment = [comments firstObject];
            if (![firstComment.Text isEqualToString:@""]) {
                if (self.comments) {
                    self.comments = [comments mutableCopy];}
                else{
                    self.comments = [NSMutableArray arrayWithArray:comments];}
                [self showComment:post];
            }
            else {
                [self showStoryOfPost:post];
            }
        
        
        }];}
}
-(void)showComment:(HNPost*)post{
    CommentsViewController *cvc=[[CommentsViewController alloc] init];
    //The post that we comment reply to
    cvc.replyPost = post;
    cvc.view.frame=CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    //FoldingTableView *cvcView=(FoldingTableView*)cvc.view;
    //[cvcView captureSuperViewScreenShot:self.view afterScreenUpdate:YES];
    //[self.view addSubview:cvcView];
    [self.view addSubview:cvc.view];
    POPSpringAnimation *segueAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    segueAnimation.toValue=[NSValue valueWithCGRect:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height)];
    segueAnimation.springBounciness=5.0f;
    segueAnimation.springSpeed=20.0f;
    //[cvcView pop_addAnimation:segueAnimation forKey:nil];
    [cvc.view pop_addAnimation:segueAnimation forKey:nil];

}
- (UIImage*)captureSuperViewScreenShot:(UIView *)view afterScreenUpdate:(BOOL)update
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES,0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:update];
    return UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}
-(void)showStoryOfPost:(HNPost*)post{
    [self saveTheListOfReadPost];
    [self.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:NO];
    [self.tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
     self.tableView.scrollEnabled=NO;
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:post.UrlString]];
    CGRect frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    FoldingWebView *foldView = [[FoldingWebView alloc] initWithFrame:frame request:request];
    foldView.delegate=self;
    [foldView captureSuperViewScreenShot:self.view afterScreenUpdate:YES];
    [self.view addSubview:foldView];
   POPSpringAnimation *segueAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    segueAnimation.toValue=[NSValue valueWithCGRect:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height)];
    segueAnimation.springBounciness=5.0f;
    segueAnimation.springSpeed=20.0f;
    [foldView pop_addAnimation:segueAnimation forKey:nil];
}
-(void)foldingViewHasClosed{
    NSLog(@"closed");
    self.tableView.scrollEnabled=YES;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    
    //Displaying the last cell, so we will load more stories
    if(indexPath.row == [self.currentPosts count] - 1){
           if (self.limitReached==NO) {
           if (![self.postType isEqualToString:@"Jobs"]){
               //loading more stories
               //start loading animation
        [[HNManager sharedManager] loadPostsWithUrlAddition:[[HNManager sharedManager] postUrlAddition] completion:^(NSArray *posts, NSString *urlAddition) {
            if (posts) {
                [self.currentPosts addObjectsFromArray:posts];
                [self.tableView reloadData];
                //stop loading animation
                if ([posts count]==0) {
                    self.limitReached=YES;
                    //no mo story
                    //stop loading animation

                }
            }
            
        }];
        }}}

    

}
@end
