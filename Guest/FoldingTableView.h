//
//  FoldingTableView.h
//  HakkaNews
//
//  Created by John on 12/3/14.
//  Copyright (c) 2014 John Smith. All rights reserved.
//

#import "FoldingView.h"

@interface FoldingTableView : FoldingView
-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;
@property(nonatomic,strong)UITableView *tableView;

@end
