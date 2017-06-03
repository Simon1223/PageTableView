//
//  ViewController.m
//  SMPageTableView
//
//  Created by huadong on 2016/12/16.
//  Copyright © 2016年 Simon.H. All rights reserved.
//

#import "ViewController.h"
#import "SMPageTableView.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    SMPageTableView *pageTable;
    NSArray *titles;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    titles = @[@"分类一",@"分类二",@"分类三"];
    
    pageTable = [[SMPageTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain items:titles itemViewHeight:44];
    pageTable.isShowHeaderView = YES;
    pageTable.itemTitleSelectColor = [UIColor redColor];
    pageTable.itemTitleDeselectColor = [UIColor blackColor];
    pageTable.itemTitleFont = [UIFont systemFontOfSize:17];
    [self.view addSubview:pageTable];
    
    pageTable.tableHeaderView = [pageTable pageHeaderViewWithContent:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4" headerType:SMPageHeaderTypeVideo headerBlock:^(NSString *contentURL, BOOL flag) {
        NSLog(@"-------%@",contentURL);
    }];
    
    [pageTable loadItemBlock:^(id itemObject) {
        if ([itemObject isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)itemObject;
            NSLog(@"---------%ld",(long)btn.tag);
        }
    }];
    
    [pageTable.tableArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UITableView class]]) {
            UITableView *table = (UITableView *)(pageTable.tableArray[idx]);
            table.delegate = self;
            table.dataSource = self;
            table.rowHeight = UITableViewAutomaticDimension;
            table.estimatedRowHeight = 100;
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (tableView.tag) {
        case 0:
            return 10;
            break;
        case 1:
            return 5;
            break;
        case 2:
            return 20;
            break;
        default:
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    
    if (indexPath.row%2 == 0) {
        cell.backgroundColor = [UIColor redColor];
        
    }
    else
    {
        cell.backgroundColor = [UIColor greenColor];
        
    }
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
