//
//  CommentsViewController.m
//  YNews
//
//  Created by John Smith on 1/18/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import "CommentsViewController.h"
#import "HNComment.h"
#import "commentCell.h"
#import <Colours/Colours.h>
#import "HNManager.h"
#import "replyVC.h"
#import "topStoriesViewController.h"
#import "FoldingTableView.h"
@interface CommentsViewController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate,FoldingViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableSet *commentID;
@property (nonatomic, strong)UIRefreshControl *refreshControl;
@property(nonatomic)BOOL userIsLoggedIn;
@property(nonatomic,strong)UIActionSheet *as;
@property(nonatomic,strong)NSIndexPath *voteIndexPath;
@property(strong,nonatomic)NSMutableArray *upvoteComment;
@property(strong,nonatomic)NSMutableArray *downvoteComment;
@property(strong,nonatomic)FoldingTableView *foldingTableView;
@end

@implementation CommentsViewController
-(FoldingTableView*)foldingTableView{
    if (!_foldingTableView) {
        _foldingTableView=[[FoldingTableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        _foldingTableView.tableView.delegate=self;
        _foldingTableView.tableView.dataSource=self;
        self.view=_foldingTableView;
    }
    return _foldingTableView;
}
/*-(void)setupFoldingTableView{
    self.view=[[FoldingTableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    ((FoldingTableView*)self.view).tableView.dataSource=self;
    ((FoldingTableView*)self.view).tableView.delegate=self;

}*/
-(void)saveListOfUpvoteComment{
    [[NSUserDefaults standardUserDefaults] setObject:self.upvoteComment forKey:@"listOfUpvoteComment"];

}
-(void)saveListOfDownvoteComment{
    [[NSUserDefaults standardUserDefaults] setObject:self.downvoteComment forKey:@"listOfDownvoteComment"];

}
-(void)retrieveListOfDownvoteComment{
    self.downvoteComment= [[[NSUserDefaults standardUserDefaults] objectForKey:@"listOfDownvoteComment"] mutableCopy];

}
-(void)retrieveListOfUpvoteComment{
    self.upvoteComment= [[[NSUserDefaults standardUserDefaults] objectForKey:@"listOfUpvoteComment"] mutableCopy];
}
- (void)initialUserSetup {
    if ([[HNManager sharedManager]userIsLoggedIn]) {
        self.userIsLoggedIn=YES;
        if (self.replyPost.Type !=PostTypeJobs) {
            //setup
            //can post reply here because not job post
            //ENABLE REPLY
        }
        else{
            //Cannot reply
            //DISABLE REPLY
        }
    }
    else{
        self.userIsLoggedIn=NO;
        //cannot reply because not logged in
        //DISABLE REPLY

    }
}
-(NSMutableSet*)commentID{
    if (!_commentID) {
        _commentID = [[NSMutableSet alloc] init];
    }
    return _commentID;
}
-(NSMutableArray*)upvoteComment{
    if (!_upvoteComment) {
        _upvoteComment = [[NSMutableArray alloc] init];
    }
    return _upvoteComment;
}
-(NSMutableArray*)downvoteComment{
    if (!_downvoteComment) {
        _downvoteComment = [[NSMutableArray alloc] init];
    }
    return _downvoteComment;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.comments count];
}

- (void)setupCellSelectedBackGroundColor:(commentCell *)cell
{
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    [selectedBackgroundView setBackgroundColor:[UIColor clearColor]];
    [cell setSelectedBackgroundView:selectedBackgroundView];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    HNComment *comment = [self.comments objectAtIndex:indexPath.row];

    [tableView registerClass:[commentCell class] forCellReuseIdentifier:CellIdentifier];

    commentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    [self configureCell:cell forRowAtIndexPath:indexPath];
    CGSize userNameSize= [cell.userName.text sizeWithAttributes:@{NSFontAttributeName:cell.userName.font}];
    cell.userName.frame=CGRectMake(15, 15, userNameSize.width, userNameSize.height);
    if ([self.commentID containsObject:comment.CommentId]) {
        cell.body.frame=CGRectZero;
    }
    else{
    CGRect bodyRectWidthNHeight=[cell.body.text boundingRectWithSize:CGSizeMake(cell.contentView.bounds.size.width-30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cell.body.font} context:nil];
    CGRect bodyRect=CGRectMake(cell.contentView.bounds.origin.x+15, cell.contentView.bounds.origin.y+cell.userName.bounds.size.height+30, bodyRectWidthNHeight.size.width, bodyRectWidthNHeight.size.height);
    cell.body.frame=bodyRect;
    }
    return cell;
}
- (void)setupCellContentViewBackgroundColor:(commentCell *)cell {
    cell.contentView.backgroundColor=[UIColor snowColor];
}
- (void)setupCellBackgroundColor:(commentCell *)cell {
    cell.backgroundColor=[UIColor snowColor];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[self.as buttonTitleAtIndex:buttonIndex] isEqualToString:@"Upvote"]) {
        HNComment *comment=[self.comments objectAtIndex:self.voteIndexPath.row];
        self.navigationItem.title = @"Upvoting...";
        //starting loading animation
        [[HNManager sharedManager] voteOnPostOrComment:comment direction:VoteDirectionUp completion:^(BOOL success) {
            if (success){
                [self.upvoteComment addObject:comment.CommentId];
                [self saveListOfUpvoteComment];
                //ENABLE SUCCESSFUL UPVOTE ANIMATION
                [((FoldingTableView*)self.view).tableView reloadRowsAtIndexPaths:@[self.voteIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                //DISABLE LOADING ANIMATION
               
            }
            else {
                //ENABLE FAILED UPVOTE ANIMATION
                //DISABLE ANIMATION
            }
        }];
        
    }
   else if ([[self.as buttonTitleAtIndex:buttonIndex] isEqualToString:@"Downvote"]) {
        HNComment *comment=[self.comments objectAtIndex:self.voteIndexPath.row];
        self.navigationItem.title = @"Downvoting...";
       //starting loading animation
        [[HNManager sharedManager] voteOnPostOrComment:comment direction:VoteDirectionDown completion:^(BOOL success) {
            if (success){
                [self.downvoteComment addObject:comment.CommentId];
                [self saveListOfDownvoteComment];
                //ENABLE SUCCESSFUL DOWNVOTE ANIMATION
                [((FoldingTableView*)self.view).tableView reloadRowsAtIndexPaths:@[self.voteIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                //DISABLE ANIMATION
            }
            else {
                //ENABLE FAILED DOWNVOTE ANIMATION
                //DISABLE ANIMATION
            }
        }];
    }
    
}

- (void)configureCell:(commentCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    HNComment *comment = [self.comments objectAtIndex:indexPath.row];
    [self setupCellBackgroundColor:cell];
    [self setupCellContentViewBackgroundColor:cell];
    [self setupCellSelectedBackGroundColor:cell];

    cell.userName.text = comment.Username;
    cell.body.text = comment.Text;
    cell.indentationLevel =comment.Level;
    cell.indentationWidth = 13;
    
    
    float indentPoints = cell.indentationLevel * cell.indentationWidth;
    
    cell.contentView.frame = CGRectMake(indentPoints,cell.contentView.frame.origin.y,cell.contentView.frame.size.width - indentPoints,cell.contentView.frame.size.height);
    
    /*if (self.userIsLoggedIn) {
        if (comment.Type != HNCommentTypeJobs){
            if ([[HNManager sharedManager]SessionUser].Karma >=500) {
                if (![self.upvoteComment containsObject:comment.CommentId] || ![self.downvoteComment containsObject:comment.CommentId]) {
                [cell setSwipeGestureWithView:action color:[UIColor ghostWhiteColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                    self.voteIndexPath=indexPath;
                    if (![self.upvoteComment containsObject:comment.CommentId] && ![self.downvoteComment containsObject:comment.CommentId]) {
                        self.as=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Upvote",@"Downvote",nil];
                        [self.as showInView:self.tableView];
                    }
                    else if (![self.upvoteComment containsObject:comment.CommentId] && [self.downvoteComment containsObject:comment.CommentId]) {
                        self.as=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Upvote",nil];
                        [self.as showInView:self.tableView];
                        
                    }
                    else if ([self.upvoteComment containsObject:comment.CommentId] && ![self.downvoteComment containsObject:comment.CommentId]) {
                        self.as=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Downvote",nil];
                        [self.as showInView:self.tableView];
                        
                    }
            }];}}
            else{
                if(![self.upvoteComment containsObject:comment.CommentId]){
                [cell setSwipeGestureWithView:action color:[UIColor ghostWhiteColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                    NSLog(@"%@ id of upvoted comment",comment.CommentId);
                    self.voteIndexPath=indexPath;
                    self.as=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Upvote",nil];
                    [self.as showInView:self.tableView];
                }];}
            }
            
        [cell setSwipeGestureWithView:submit color:[UIColor whiteColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                self.replyComment = comment;
                [self performSegueWithIdentifier:@"reply" sender:self];
            }];
        }}
     */
}

- (void)setupTableViewBackgroundColor {
    ((FoldingTableView*)self.view).tableView.backgroundColor=[UIColor snowColor];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HNComment *comment = [self.comments objectAtIndex:indexPath.row];
    //job comments cannot be collapsed
    if (comment.Type !=HNCommentTypeJobs) {
        //check to see if the comment has already been collapsed
        //collapse and expand as neccessary
    if ([self.commentID containsObject:comment.CommentId]) {
        [self.commentID removeObject:comment.CommentId];
    }
    else{
        [self.commentID addObject:comment.CommentId];
    }

        [((FoldingTableView*)self.view).tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#define contentViewVerticalPadding 15
#define contentViewSidePadding 15

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    HNComment *comment    = [self.comments objectAtIndex:indexPath.row];
    //return collapsed cell height
    CGSize userNameSize= [comment.Username sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-DemiBold" size:15]}];
    if ([self.commentID containsObject:comment.CommentId]) {
        
        return contentViewVerticalPadding*2+userNameSize.height;
    }
    else{
        //comment level *indentation width-padding
        UIFont   *textFont    = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
    CGFloat cellWidth= ((FoldingTableView*)self.view).tableView.frame.size.width-(comment.Level *13.0)-contentViewSidePadding*2;
    CGSize boundingSize = CGSizeMake(cellWidth, CGFLOAT_MAX);
    CGSize textSize = [comment.Text boundingRectWithSize:boundingSize
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{ NSFontAttributeName : textFont }
                                  context:nil].size;
        //50 is accounting for padding and username label
        return textSize.height +userNameSize.height+ contentViewVerticalPadding*3;
    }
    
}
/*-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"reply"]) {
        replyVC *rvc= segue.destinationViewController;
        if ([sender isKindOfClass:[CommentsViewController class]]) {
            rvc.replyComment = self.replyComment;
            rvc.replyQuote= self.replyComment.Text;
    }
        
        else if ([sender isKindOfClass:[UIBarButtonItem class]]){
            rvc.replyPost = self.replyPost;
        }
    }
}*/

-(void)setupLoggedIn{
    if (self.replyPost.Type !=PostTypeJobs) {
        //ENABLE REPLY
    }
    else{
        //DISABLE REPLY
    }
    self.userIsLoggedIn=YES;
    [((FoldingTableView*)self.view).tableView reloadData];
}
-(void)setupNotLoggedIn{
    //DISABLE REPLY
    self.userIsLoggedIn=NO;
    [((FoldingTableView*)self.view).tableView reloadData];
}
- (void)setupFooterView {
    ((FoldingTableView*)self.view).tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}
- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupLoggedIn) name:@"userIsLoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupNotLoggedIn) name:@"userIsNotLoggedIn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadComments) name:@"replySuccessful" object:nil];
}
-(void)viewDidLoad{
    [super viewDidLoad];
   // [self setupFoldingTableView];
    [self retrieveListOfDownvoteComment];
    [self retrieveListOfUpvoteComment];
    [self initialUserSetup];
    [self reloadComments];
    [self initialUserSetup];
    [self setupTableViewBackgroundColor];
    [self registerNotification];
    [self setupFooterView];
}
- (void)reloadComments {
    //ENABLE LOADING ANIMATION
    [[HNManager sharedManager] loadCommentsFromPost:self.replyPost completion:^(NSArray *comments) {
        if (comments){
            self.comments=comments;
            self.title = self.replyPost.Title;
            
            [((FoldingTableView*)self.view).tableView reloadData];
            self.navigationItem.title = self.title ;
           //DISABLE LOADING ANIMATION
        }
        else{
            //DISABLE LOADING ANIMATION
        }
    }];
}
@end