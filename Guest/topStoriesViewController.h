//
//  topStoriesViewController.h
//  
//
//  Created by John Smith on 12/24/13.
//  Copyright (c) 2013 John Smith. All rights reserved.
//
#import <UIKit/UIKit.h>
@interface topStoriesViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *currentPosts;
@property (nonatomic) NSUInteger postType;
@property(nonatomic)BOOL reloadStories;
@property(nonatomic)BOOL limitReached;
-(void)getStories;
-(void)setupAd;
@end
