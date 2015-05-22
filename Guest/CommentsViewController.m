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
#import "topStoriesViewController.h"
#import "FoldingTableView.h"
#import "FBShimmeringLayer.h"

@interface CommentsViewController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate,FoldingViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableSet *commentID;
@property (nonatomic, strong)UIRefreshControl *refreshControl;
@property(nonatomic)BOOL userIsLoggedIn;
@property(nonatomic,strong)UIActionSheet *as;
@property(nonatomic,strong)NSIndexPath *voteIndexPath;
@property(strong,nonatomic)NSMutableArray *upvoteComment;
@property(strong,nonatomic)NSMutableArray *downvoteComment;
@property(strong,nonatomic)FBShimmeringLayer *loadingLayer;
@end

@implementation CommentsViewController
@dynamic view;
-(void)turnOffShimmeringLayer{
    self.loadingLayer.shimmering=NO;
    self.loadingLayer.opacity=0.0;
}
-(void)turnOnShimmeringLayer{
    self.loadingLayer.shimmering=YES;
    self.loadingLayer.opacity=0.8;
}
-(void)loadView{
    self.view=[[FoldingTableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    ((FoldingTableView*)self.view).tableView.dataSource=self;
    ((FoldingTableView*)self.view).tableView.delegate=self;
}

-(NSMutableSet*)commentID{
    if (!_commentID) {
        _commentID = [[NSMutableSet alloc] init];
    }
    return _commentID;
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

- (void)configureCell:(commentCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    HNComment *comment = [self.comments objectAtIndex:indexPath.row];
    cell.backgroundColor=[UIColor snowColor];
    cell.contentView.backgroundColor=[UIColor snowColor];
    [self setupCellSelectedBackGroundColor:cell];

    cell.userName.text = comment.Username;
    cell.body.text = comment.Text;
    cell.indentationLevel =comment.Level;
    cell.indentationWidth = 13;
    
    
    float indentPoints = cell.indentationLevel * cell.indentationWidth;
    
    cell.contentView.frame = CGRectMake(indentPoints,cell.contentView.frame.origin.y,cell.contentView.frame.size.width - indentPoints,cell.contentView.frame.size.height);
    

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



- (void)setupFooterView {
    ((FoldingTableView*)self.view).tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)viewDidLoad{
    [super viewDidLoad];
   // [self setupFoldingTableView];
    self.loadingLayer=[FBShimmeringLayer layer];
    self.loadingLayer.frame=CGRectMake(0,0, self.view.bounds.size.width, 5);
    self.loadingLayer.shimmeringOpacity=0.1f;
    self.loadingLayer.shimmeringSpeed=300;
    self.loadingLayer.shimmeringPauseDuration=0.1;
    CALayer *layer=[CALayer layer];
    layer.frame=self.loadingLayer.bounds;
    layer.backgroundColor=[UIColor turquoiseColor].CGColor;
    self.loadingLayer.contentLayer=layer;
    [self.view.layer addSublayer:self.loadingLayer];

    [self reloadComments];
    [self setupTableViewBackgroundColor];
    [self setupFooterView];
}
- (void)reloadComments {
    [self turnOnShimmeringLayer];
    [[HNManager sharedManager] loadCommentsFromPost:self.replyPost completion:^(NSArray *comments) {
        if (comments){
            self.comments=comments;
            self.title = self.replyPost.Title;
            
            [((FoldingTableView*)self.view).tableView reloadData];
            [self turnOffShimmeringLayer];
        }
        else{
            [self turnOffShimmeringLayer];
        }
    }];
}
@end