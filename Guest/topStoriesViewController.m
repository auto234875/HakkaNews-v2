//
//  topStoriesViewController.m
//
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
@interface topStoriesViewController () <UIGestureRecognizerDelegate,POPAnimationDelegate,UIScrollViewDelegate,UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate,FoldingViewDelegate>
@property (nonatomic, strong) NSMutableArray *readPost;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
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
@property(nonatomic,strong)CALayer *topView;
@property(nonatomic,strong)CALayer *bottomView;
@property(nonatomic,strong)CATransformLayer *scaleNTranslationLayer;
@property(nonatomic,strong)CAGradientLayer *bottomShadowLayer;
@property(nonatomic,strong)CAGradientLayer *topShadowLayer;
@property(nonatomic,strong)CALayer *imprintLayer1;
@property(nonatomic,strong)CALayer *imprintLayer2;
@property(nonatomic,strong)CALayer *backImageLayer;
@property(nonatomic,strong)CALayer *avatarLayer;
@property(nonatomic,strong)CAGradientLayer *backGradientLayer;
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
    self.postType=@"New";
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
    [cell.postDetail setTitle:[NSString stringWithFormat:@"%i Points  %i Comments", post.Points, post.CommentCount]
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
    NSIndexPath *indexPath=[NSIndexPath indexPathForItem:sender.tag inSection:0];
    if (post.Type==PostTypeDefault) {
        //if there is no comment, we don't segue
        if (post.CommentCount==0){
            //show animation for no comment
            return;
        }
        else {
            [self showComment:post indexPath:indexPath];
            }
        
    }
    else if (post.Type == PostTypeAskHN){
        //we always show the comment because it's askHN
        //askHN always have at least 1 comment
        [self.readPost addObject:post.PostId];
        [self showComment:post indexPath:indexPath];
        
    }
    //Job Post, check to see if it's a self post or webpage by loading the first comment and checking the string
    else if (post.Type == PostTypeJobs){[[HNManager sharedManager] loadCommentsFromPost:post completion:^(NSArray *comments) {
        HNComment *firstComment = [comments firstObject];
        if (![firstComment.Text isEqualToString:@""]) {
            [self.readPost addObject:post.PostId];
            [self showComment:post indexPath:indexPath];
            }
        else {
            [self.readPost addObject:post.PostId];
            [self showStoryOfPost:post indexPath:indexPath];
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
    //retrieve the corresponding post
    HNPost *post=[self.currentPosts objectAtIndex:indexPath.row];
    //add it to the the list of read posts
    [self.readPost addObject:post.PostId];
    //if the post is default, we go to the webpage
    if (post.Type == PostTypeDefault){
        [self showStoryOfPost:post indexPath:indexPath];

    }
    //if the post is ask, we show the comment because AskHN is always self-post on HN
    else if (post.Type == PostTypeAskHN){
        [self showComment:post indexPath:indexPath];

        }
    //if it is a job post, we have to load the comment and check to see if it is self post or from a webpage
    else if (post.Type== PostTypeJobs){
        [[HNManager sharedManager] loadCommentsFromPost:post completion:^(NSArray *comments) {
            //getting the first comment and checking if the string is empty
            //the string is NEVER nil but it can contain no character if the post is an external site
            HNComment *firstComment = [comments firstObject];
            if (![firstComment.Text isEqualToString:@""]) {
                [self showComment:post indexPath:indexPath];
            }
            else {
                [self showStoryOfPost:post indexPath:indexPath];
            }
        
        
        }];}
}
-(void)deselectAndRefreshRowAtIndexPath:(NSIndexPath*)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
-(void)showComment:(HNPost*)post indexPath:(NSIndexPath*)indexPath{
    [self saveTheListOfReadPost];
    [self deselectAndRefreshRowAtIndexPath:indexPath];
    self.tableView.scrollEnabled=NO;
    CommentsViewController *cvc=[[CommentsViewController alloc] init];
    //The post that we comment reply to
    cvc.replyPost = post;
    cvc.view.frame=self.view.frame;
    FoldingTableView *cvcView=(FoldingTableView*)cvc.view;
    cvcView.delegate=self;
    [cvcView captureSuperViewScreenShot:self.view afterScreenUpdate:YES];
    [self unfoldView:^(BOOL finished) {
        if (finished){
            [self.view addSubview:cvcView];
            self.view.userInteractionEnabled=YES;
            [self.scaleNTranslationLayer removeFromSuperlayer];
            [self.topView removeFromSuperlayer];
            [self.bottomView removeFromSuperlayer];
        }
    }];
}
-(void)showStoryOfPost:(HNPost*)post indexPath:(NSIndexPath*)indexPath{
    [self saveTheListOfReadPost];
    [self deselectAndRefreshRowAtIndexPath:indexPath];
     self.tableView.scrollEnabled=NO;
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:post.UrlString]];
    FoldingWebView *foldView = [[FoldingWebView alloc] initWithFrame:self.view.bounds request:request];
    foldView.delegate=self;
    [foldView captureSuperViewScreenShot:self.view afterScreenUpdate:YES];
    [self unfoldView:^(BOOL finished) {
        if (finished){
            [self.view addSubview:foldView];
            self.view.userInteractionEnabled=YES;
            [self.scaleNTranslationLayer removeFromSuperlayer];
            [self.topView removeFromSuperlayer];
            [self.bottomView removeFromSuperlayer];
        }
            }];

   
}
typedef void(^myCompletion)(BOOL);

-(void)unfoldView:(myCompletion)completionBlock{
    self.view.userInteractionEnabled=NO;
    [self addTopView];
    [self addBottomView];
    POPBasicAnimation *anim=[POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    POPBasicAnimation *rotationAnimation=[POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationX];
    rotationAnimation.toValue=@(-M_PI*0.99f);
    rotationAnimation.duration=0;
    rotationAnimation.removedOnCompletion=YES;
    anim.removedOnCompletion=YES;
    [self.topView pop_addAnimation:rotationAnimation forKey:nil];
     anim.toValue=[NSValue valueWithCGSize:CGSizeMake(0.01f, 0.01f)];
     anim.duration=0;
     [anim setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
     if (finished){
         [self.view.layer addSublayer:self.scaleNTranslationLayer];
         const CGFloat maxScaleAngle=90.0f;
         const CGFloat maxDownScaleConversionFactor= 1.0f-(maxScaleAngle/650.0f);
         POPBasicAnimation *anim1=[POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
         anim1.toValue=[NSValue valueWithCGSize:CGSizeMake(maxDownScaleConversionFactor, maxDownScaleConversionFactor)];
         anim1.duration=0.2f;
         anim1.removedOnCompletion=YES;
         [anim1 setCompletionBlock:^(POPAnimation *anim1, BOOL finished) {
             if (finished) {
                 POPBasicAnimation *unfold=[POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationX];
                 POPBasicAnimation *expand=[POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
                 unfold.toValue=@(0);
                unfold.duration=0.6f;
                 unfold.delegate=self;
                 unfold.removedOnCompletion=YES;
                 [unfold setCompletionBlock:^(POPAnimation *unfold, BOOL finished) {
                     completionBlock(YES);
                 }];
                 expand.toValue=[NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
                 expand.duration=0.6f;
                 expand.removedOnCompletion=YES;
                 [self.scaleNTranslationLayer pop_addAnimation:expand forKey:nil];
                 [self.topView pop_addAnimation:unfold forKey:@"unfold"];
             }
         }];
     [self.scaleNTranslationLayer pop_addAnimation:anim1 forKey:nil];
     }
     }];
    [self.scaleNTranslationLayer pop_addAnimation:anim forKey:nil];

}
-(void)foldingViewHasClosed{
    self.tableView.scrollEnabled=YES;
}
-(CATransformLayer*)scaleNTranslationLayer{
    if (!_scaleNTranslationLayer) {
        _scaleNTranslationLayer=[CATransformLayer layer];
        _scaleNTranslationLayer.frame=self.view.bounds;
    }
    return _scaleNTranslationLayer;
}
- (void)addTopView
{
    self.topView=[CALayer layer];
    self.topView.backgroundColor=[UIColor whiteColor].CGColor;
    self.topView.opaque=YES;
    self.topView.allowsEdgeAntialiasing=YES;
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 2.5f / -4600.0f;
    self.topView.transform=transform;

    self.topView.contentsScale=[UIScreen mainScreen].scale;
    self.topView.frame=CGRectMake(0.0f,
                                  0.0f,
                                  CGRectGetWidth(self.scaleNTranslationLayer.bounds),
                                  CGRectGetMidY(self.scaleNTranslationLayer.bounds));
    self.topView.anchorPoint = CGPointMake(0.5f, 1.0f);
    self.topView.position = CGPointMake(CGRectGetMidX(self.scaleNTranslationLayer.bounds), CGRectGetMidY(self.scaleNTranslationLayer.bounds));
    self.topShadowLayer.opacity=0;
    self.backImageLayer.opacity=1.0f;
    self.backGradientLayer.opacity = 0.3f;
   [self.topView addSublayer:self.topShadowLayer];
    [self.topView addSublayer:self.backImageLayer];
    [self.backImageLayer addSublayer:self.avatarLayer];
    [self.backImageLayer addSublayer:self.backGradientLayer];
    [self.scaleNTranslationLayer addSublayer:self.topView];
}
- (void)addBottomView
{
    self.bottomView=[CALayer layer];
    self.bottomView.backgroundColor=[UIColor whiteColor].CGColor;
    self.bottomView.frame =CGRectMake(0.0f,
                                      CGRectGetMidY(self.scaleNTranslationLayer.bounds),
                                      CGRectGetWidth(self.scaleNTranslationLayer.bounds),
                                      CGRectGetMidY(self.scaleNTranslationLayer.bounds));
    self.bottomView.opaque=YES;
    self.bottomView.shadowColor=[UIColor blackColor].CGColor;
    self.bottomView.shadowOffset=CGSizeMake(0,0);
    self.bottomView.shadowOpacity =0.85f ;
    self.bottomView.shadowRadius = 25.0f;
    [self.bottomView setShadowPath:[UIBezierPath bezierPathWithRect:CGRectMake(self.bottomView.bounds.origin.x, self.bottomView.bounds.origin.y+50, self.bottomView.bounds.size.width, self.bottomView.bounds.size.height-50)].CGPath];
    [self.bottomView addSublayer:self.imprintLayer1];
    [self.bottomView addSublayer:self.imprintLayer2];
    self.bottomShadowLayer.opacity = 0;
    [self.bottomView addSublayer:self.bottomShadowLayer];
    [self.scaleNTranslationLayer addSublayer:self.bottomView];
}
-(CALayer*)imprintLayer2{
    if (!_imprintLayer2) {
        _imprintLayer2=[CALayer layer];
        _imprintLayer2.frame=CGRectMake(0, self.bottomView.bounds.origin.y+1.7f, self.bottomView.bounds.size.width, 0.3f);
        _imprintLayer2.backgroundColor=[UIColor blackColor].CGColor;
        _imprintLayer2.opacity=0.03f;
    }
    return _imprintLayer2;
}
-(CALayer*)imprintLayer1{
    if (!_imprintLayer1) {
        _imprintLayer1=[CALayer layer];
        _imprintLayer1.frame=CGRectMake(0, self.bottomView.bounds.origin.y+0.6f, self.bottomView.bounds.size.width, 0.3f);
        _imprintLayer1.backgroundColor=[UIColor blackColor].CGColor;
        _imprintLayer1.opacity=0.06f;
        
    }
    return _imprintLayer1;
}
-(CAGradientLayer*)bottomShadowLayer{
    if (!_bottomShadowLayer) {
        _bottomShadowLayer = [CAGradientLayer layer];
        _bottomShadowLayer.frame = self.bottomView.bounds;
        _bottomShadowLayer.colors = @[(id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor];
    }
    return _bottomShadowLayer;
}
-(CAGradientLayer*)topShadowLayer{
    if (!_topShadowLayer) {
        _topShadowLayer = [CAGradientLayer layer];
        _topShadowLayer.frame = self.topView.bounds;
        _topShadowLayer.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor];
    }
    return _topShadowLayer;
}
-(CALayer*)avatarLayer{
    if (!_avatarLayer) {
        _avatarLayer=[CALayer layer];
        _avatarLayer.contentsScale=[UIScreen mainScreen].scale;
        _avatarLayer.contents=(__bridge id)[UIImage imageNamed:@"avatar"].CGImage;
        _avatarLayer.frame=CGRectMake(self.backImageLayer.bounds.size.width-115.0f, self.backImageLayer.bounds.size.height-115.0f, 100.0f, 100.0f);
        CATransform3D  rot2 = CATransform3DMakeRotation(M_PI, -1.0f, 0.f, 0.f);
        _avatarLayer.transform=rot2;
        _avatarLayer.cornerRadius=50.0f;
        _avatarLayer.borderWidth=0.5f;
        _avatarLayer.borderColor=[UIColor whiteColor].CGColor;
        _avatarLayer.masksToBounds=YES;
    }
    return _avatarLayer;
}
-(CALayer*)backImageLayer{
    if (!_backImageLayer) {
        _backImageLayer=[CALayer layer];
        _backImageLayer.frame=self.topView.bounds;
        _backImageLayer.backgroundColor=[UIColor blackColor].CGColor;
        _backImageLayer.opaque=YES;
    }
    return _backImageLayer;
}
-(CAGradientLayer*)backGradientLayer{
    if (!_backGradientLayer) {
        _backGradientLayer=[CAGradientLayer layer];
        _backGradientLayer.frame=self.topView.bounds;
        UIColor *fluorescentColor=[UIColor colorWithRed:141/255.0f green:218/255.0f blue:247/255.0f alpha:0.0f];
        _backGradientLayer.colors=@[(__bridge id)[UIColor clearColor].CGColor, (__bridge id)fluorescentColor.CGColor,(__bridge id)[UIColor whiteColor].CGColor,(__bridge id)[UIColor whiteColor].CGColor,(__bridge id)fluorescentColor.CGColor,(__bridge id)[UIColor clearColor].CGColor];
        _backGradientLayer.startPoint=CGPointMake(0, -0.5f);
        _backGradientLayer.endPoint=CGPointMake(1, 1);
    }
    return _backGradientLayer;
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
- (void)pop_animationDidApply:(POPAnimation *)anim
{
    CGFloat angle=(-([[self.topView valueForKeyPath:@"transform.rotation.x"]floatValue]*(180.0f/M_PI)));
    if (angle > 90.0f){
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        self.backGradientLayer.opacity = 0.3f;
        self.backImageLayer.opacity=1.0f;
        self.bottomShadowLayer.opacity = 0.5f;
        self.topShadowLayer.opacity = 0.5f;
        [CATransaction commit];
        CGFloat shineGradientFactor=angle*0.02071429f;
        [CATransaction begin];
        [CATransaction setValue:@0.016f forKey:kCATransactionAnimationDuration];
        self.backGradientLayer.locations=@[[NSNumber numberWithFloat:-2.45f+shineGradientFactor],[NSNumber numberWithFloat:-2.4f+shineGradientFactor],[NSNumber numberWithFloat:-2.34f+shineGradientFactor],[NSNumber numberWithFloat:-2.09f+shineGradientFactor],[NSNumber numberWithFloat:-2.05f+shineGradientFactor],[NSNumber numberWithFloat:-2.0f+shineGradientFactor]];
        [CATransaction commit];
    }else{
     [CATransaction begin];
     [CATransaction setValue:(id)kCFBooleanTrue
     forKey:kCATransactionDisableActions];
        self.backGradientLayer.opacity = 0.0f;
     self.backImageLayer.opacity=0.0f;
     self.bottomShadowLayer.opacity = angle/180.0f;
     self.topShadowLayer.opacity = angle/180.0f;
     [CATransaction commit];
    }
}
@end
