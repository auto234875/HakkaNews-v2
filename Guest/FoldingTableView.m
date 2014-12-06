//
//  FoldingTableView.m
//  HakkaNews
//
//  Created by John on 12/3/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import "FoldingTableView.h"
@interface FoldingTableView()<UIScrollViewDelegate,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic)CALayer *pullDownLayer;
@end
@implementation FoldingTableView
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self=[super initWithFrame:frame];
    if (self) {
        _tableView=[[UITableView alloc] initWithFrame:self.bounds style:style];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        [self addSubview:_tableView];
        _pullDownLayer=[CALayer layer];
        _pullDownLayer.frame=CGRectMake(self.tableView.bounds.size.width/2 - 25,60, 50, 20);
        _pullDownLayer.contents=(__bridge id)([UIImage imageNamed:@"down"].CGImage);
        _pullDownLayer.opacity=0;
        _pullDownLayer.contentsScale=[UIScreen mainScreen].scale;
        [self.tableView.layer addSublayer:_pullDownLayer];
        self.subclassView=_tableView;
    }
    return self;
}
-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer==self.foldGestureRecognizer) {
        CGPoint location = [gestureRecognizer locationInView:self];
        CGPoint startingPoint=[gestureRecognizer translationInView:self];
        if (self.tableView.contentOffset.y==0 && startingPoint.y >0) {
            self.tableView.scrollEnabled=NO;
            
            return YES;
        }
        else{
            if (location.y<=80) {
                self.tableView.scrollEnabled=NO;
                
                return YES;
            }
            else{
                return NO;
            }
        }
    }
    else{
        return YES;
    }
}
-(void)handlePanControl{
    self.pullDownLayer.opacity=0;
}
-(void)rotateToOriginCompletionBlockMethod{
    [super rotateToOriginCompletionBlockMethod];
    self.tableView.scrollEnabled=YES;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView];
    if (translation.y < 0 ) {
        self.pullDownLayer.opacity=0;
    }
    else{
        CGPoint velocity=[scrollView.panGestureRecognizer velocityInView:scrollView];
        //velocity.y > x , lower x - higher sensitivity
        if (velocity.y > 1200) {
            self.pullDownLayer.opacity=0.4f;
        }
    }
    
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y==0) {
        self.pullDownLayer.opacity=0.4f;
    }
}
-(void)dealloc{
    [self.tableView setDelegate:nil];
}

@end
