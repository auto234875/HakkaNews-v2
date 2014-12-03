//
//  postCell.m
//  YNews
//
//  Created by John Smith on 1/23/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import "postCell.h"
#import <MCFireworksButton.h>
#import <Colours/Colours.h>

@implementation postCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(UILabel*)postTitle{
    if (!_postTitle) {
        _postTitle=[[UILabel alloc] init];
        _postTitle.font=[UIFont fontWithName:@"AvenirNext-DemiBold" size:14];
        _postTitle.textColor=[UIColor blackColor];
        _postTitle.textAlignment=NSTextAlignmentLeft;
        _postTitle.numberOfLines=0;

        [self.contentView addSubview:_postTitle];
    }
    return _postTitle;
}
-(UIButton*)postDetail{
    if (!_postDetail) {
        _postDetail=[[UIButton alloc] init];
        _postDetail.titleLabel.font=[UIFont fontWithName:@"AvenirNext-Regular" size:11];
        [_postDetail setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_postDetail setBackgroundColor:[UIColor snowColor]];
        _postDetail.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
        _postDetail.contentVerticalAlignment=UIControlContentHorizontalAlignmentCenter;
        _postDetail.titleLabel.lineBreakMode=NO;
        
        _postDetail.layer.cornerRadius=5.0f;
        
        
        [self.contentView addSubview:_postDetail];
    }
    return _postDetail;
}

-(MCFireworksButton*)likeButton{
    if (!_likeButton) {
        _likeButton=[[MCFireworksButton alloc] init];
        [_likeButton setTintColor:[UIColor redColor]];
        _likeButton.particleImage = [UIImage imageNamed:@"Sparkle"];
        _likeButton.particleScale = 0.05;
        _likeButton.particleScaleRange = 0.02;
        [self.contentView addSubview:_likeButton];
    }
    return _likeButton;
}
-(UIButton*)actionButton{
    if (!_actionButton) {
        _actionButton=[[UIButton alloc] init];
        
        UIImageView *actionBackgroundImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"action"] highlightedImage:[UIImage imageNamed: @"actionHighlighted"]];
        actionBackgroundImageView.frame=CGRectMake(9.5f, 9.5f, 25, 25);
        [_actionButton addSubview:actionBackgroundImageView];
        [self.contentView addSubview:_actionButton];
    }
    return _actionButton;
}
@end
