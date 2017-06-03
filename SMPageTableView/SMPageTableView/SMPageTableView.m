//
//  SMPageTableView.m
//  SMPageTableView
//
//  Created by huadong on 2016/12/16.
//  Copyright © 2016年 Simon.H. All rights reserved.
//

#import "SMPageTableView.h"
#import "SDCycleScrollView.h"
#import "JWPlayer.h"

#define itemHeight 44
#define itemFont 17

@interface SMPageTableView ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
{
    UIPanGestureRecognizer *headerPan;
    UIPanGestureRecognizer *itemPan;
    BOOL canResponce;     //所有列表都响应手势
    CGFloat pageScrollViewHeight; //重建pageTableView时sectionFooterView的高度
}

@end

@implementation SMPageTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style items:(NSArray *)items itemViewHeight:(CGFloat)height
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.items = items;
        self.itemViewHeight = height;
        self.delegate = self;
        self.dataSource = self;
        
        CGFloat point_h = 0;
        point_h = CGRectGetHeight(self.frame) - (self.itemViewHeight?self.itemViewHeight:itemHeight);
        
        _pageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), point_h)];
        _pageScrollView.backgroundColor = [UIColor purpleColor];
        _pageScrollView.delegate = self;
        _pageScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame)*self.items.count, point_h);
        
        //循环创建table
        self.tableArray = [NSMutableArray new];
        for (int i=0; i<self.items.count; i++) {
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)*i, 0, CGRectGetWidth(self.frame), point_h) style:UITableViewStylePlain];
            tableView.tag = i;
            tableView.rowHeight = UITableViewAutomaticDimension;
            tableView.estimatedRowHeight = 100;
            tableView.tableFooterView = [UIView new];
            tableView.tableFooterView.backgroundColor = [UIColor clearColor];
            tableView.showsVerticalScrollIndicator = NO;
            tableView.showsHorizontalScrollIndicator = NO;
            
            [_tableArray addObject:tableView];
            [_pageScrollView addSubview:tableView];
      
            //添加监听
            [tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        }
        
        canResponce = YES;
        self.bounces = NO;
        self.tableFooterView = [UIView new];
        self.tableFooterView.backgroundColor = [UIColor clearColor];
        
        self.tableFooterView = _pageScrollView;
    }
    
    return self;
}

/**
 * 列表头部
 */
- (UIView *)pageHeaderViewWithContent:(id)contentObject headerType:(SMPageHeaderType)type headerBlock:(SMPageHeaderBlock)block
{
    self.pageHeaderType  = type;
    self.pageHeaderBlock = block;
    self.isShowHeaderView = YES;
    self.pageHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame)*9/16)];
    //根据头部内容创建
    switch (type) {
        case SMPageHeaderTypePicture:
        {
            //图片（支持一张或多张）
            NSArray *contentArray;
            if ([contentObject isKindOfClass:[NSString class]]) {
                contentArray = @[contentObject];
            }
            else if ([contentObject isKindOfClass:[NSArray class]])
            {
                contentArray = contentObject;
            }
            
            SDCycleScrollView *imageScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame),CGRectGetWidth(self.frame)*9/16) imageURLStringsGroup:contentArray];
            imageScrollView.infiniteLoop = YES;
            imageScrollView.autoScroll = NO;
            [self.pageHeaderView addSubview:imageScrollView];
            
            if (self.pageHeaderBlock != nil) {
                
            }
        }
            break;
        case SMPageHeaderTypeVideo:
        {
            //视频 (支持直接播放)
            NSURL *contentURL; //http://120.25.226.186:32812/resources/videos/minion_01.mp4
            if ([contentObject isKindOfClass:[NSString class]])
            {
                contentURL = [NSURL URLWithString:contentObject];
            }
            
            JWPlayer *player = [[JWPlayer alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame),CGRectGetWidth(self.frame)*9/16)];
            [player updatePlayerWith:contentURL];
            [self.pageHeaderView addSubview:player];
            
            if (self.pageHeaderBlock != nil)
            {
                block([contentURL absoluteString],player.isPlaying);
            }
        }
            break;
        default:
            break;
    }
    
    headerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pageHeaderTap:)];
    headerPan.delegate = self;
    [self.pageHeaderView addGestureRecognizer:headerPan];
    
    return self.pageHeaderView;
}

- (UIView *)pageItemsWithType:(SMPageItemType)type
{
    self.isShowItemView = YES;
    _itemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), self.itemViewHeight?self.itemViewHeight:itemHeight)];
    
    //动态标题个数
    _itemScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), self.itemViewHeight?self.itemViewHeight:itemHeight)];
    _itemScrollView.backgroundColor = [UIColor clearColor];
    _itemScrollView.bounces = NO;
    _itemScrollView.showsVerticalScrollIndicator = NO;
    _itemScrollView.showsHorizontalScrollIndicator = NO;
    [_itemView addSubview:_itemScrollView];
    
    CGFloat contentLenght = 0;
    for (int i=0; i<_items.count; i++)
    {
        CGFloat btnWidth;
        if (type == SMPageItemTypeMiddle)
        {
            CGSize stringSize = [_items[i] sizeWithAttributes:@{ NSFontAttributeName : self.itemTitleFont?self.itemTitleFont:[UIFont systemFontOfSize:itemFont]}];
            btnWidth = stringSize.width + 52;
        }
        else if (type == SMPageItemTypeAverage)
        {
            btnWidth = CGRectGetWidth(self.frame)/_items.count;
        }
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(contentLenght, 0, btnWidth, self.itemViewHeight?self.itemViewHeight:itemHeight)];
        btn.tag = i;
        [btn setTitle:_items[i] forState:UIControlStateNormal];
        
        btn.titleLabel.font = self.itemTitleFont?self.itemTitleFont:[UIFont systemFontOfSize:itemFont];
        [btn setTitleColor:self.itemTitleDeselectColor forState:UIControlStateNormal];
        
        [btn setTitleColor:self.itemTitleSelectColor forState:UIControlStateSelected];
        
        [btn addTarget:self action:@selector(selectItem:) forControlEvents:UIControlEventTouchUpInside];
        [_itemScrollView addSubview:btn];
        
        contentLenght += btnWidth;
        
        if (i<_items.count - 1) {
            UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(btn.frame.size.width - 1, 10, 1, 20)];
            line.tag = 100;
            line.backgroundColor = self.itemTitleDeselectColor;
            [btn addSubview:line];
        }
        
        if (i == 0) {
            btn.selected = YES;
        }
    }
    
    if (contentLenght > CGRectGetWidth(self.frame)) {
        //超出滑动
        _itemScrollView.contentSize = CGSizeMake(contentLenght, 40);
    }
    else
    {
        //未超出，居中显示
        if (type == SMPageItemTypeMiddle)
        {
            _itemScrollView.frame = CGRectMake(0, 0, contentLenght, 40);
            _itemScrollView.center = CGPointMake(CGRectGetWidth(self.frame)/2, 20);
        }
        else if (type == SMPageItemTypeAverage)
        {
            
        }
    }
    
    itemPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:nil];
    itemPan.delegate = self;
    [_itemView addGestureRecognizer:itemPan];
    
    return _itemView;
}

- (void)loadItemBlock:(SMPageItemBlock)block
{
    self.pageItemBlock = block;
}

- (void)selectItem:(UIButton *)sender
{
    self.currentPage = sender.tag;
    [self selectItemInPage:sender.tag];
    [self.pageScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.frame)*self.currentPage, 0) animated:NO];
}

- (void)selectItemInPage:(NSInteger)page
{
    for (UIView *view in self.itemScrollView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            if (btn.tag == page) {
                btn.selected = YES;
                if (self.pageItemBlock != nil) {
                    self.pageItemBlock(btn);
                }
            }
            else
            {
                btn.selected = NO;
            }
        }
    }
}

#pragma mark ------------UITableViewDelegate-----------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.itemViewHeight?self.itemViewHeight:itemHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self pageItemsWithType:SMPageItemTypeAverage];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    
    return cell;
}

//
- (void)pageHeaderTap:(UIPanGestureRecognizer *)pan
{
    
}

#pragma mark ----------解决滑动冲突-----------
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(nonnull UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.pageHeaderView] || [touch.view isDescendantOfView:self.itemView]) {//判断如果点击的是tableView的cell，就把手势给关闭了
        return NO;//关闭手势
    }
    
    //否则手势存在
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer.view isKindOfClass:[UITableView class]]) {
        if (canResponce) {
            return YES;
        }
        return NO;
    }
    return NO;
}

#pragma mark ---------监听tableview的contentOffSet的变化----------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([object isKindOfClass:[UITableView class]])
    {
        UITableView *table = (UITableView *)object;
        if (table.tag == self.currentPage) {
            table.scrollEnabled = YES;
            NSLog(@"old : %@  new : %@",[change objectForKey:@"old"],[change objectForKey:@"new"]);
            CGPoint oldPoint = [[change objectForKey:@"old"] CGPointValue];
            CGPoint newPoint = [[change objectForKey:@"new"] CGPointValue];
            CGFloat header_h = CGRectGetWidth(self.frame)*9/16;
            
            table.scrollEnabled = YES;
            if (self.contentOffset.y>0 && self.contentOffset.y<header_h) {
                if (newPoint.y >= 0) {
                    [table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
                }
                else
                {
                    table.scrollEnabled = NO;
                }
            }
            else if (self.contentOffset.y == 0){
                NSLog(@"botoom");
            }
            else if (self.contentOffset.y == header_h)
            {
                NSLog(@"top");
            }
            
            
//            if (newPoint.y > oldPoint.y) {
//                // 上滑
//                NSLog(@"table向上滑动");
//                if (self.contentOffset.y>0 && self.contentOffset.y<header_h) {
//                    [table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
//                }
//            }
//            else {
//                // 下滑
//                NSLog(@"table向下滑动----pageOffset_Y=%f----tableOffset_Y=%f",self.contentOffset.y,table.contentOffset.y);
//                if (newPoint.y>0) {
//                    canResponce = NO;
//                }
//                else{
//                    canResponce = YES;
//                    if (self.contentOffset.y>5 && self.contentOffset.y<header_h-5) {
//                        table.scrollEnabled = NO;
//                    }
//                    else{
//                        table.scrollEnabled = YES;
//                    }
//                }
//            }
        }
    }
    
}

#pragma mark ---------UIScrollViewDelegate---------

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.pageScrollView) {
        int page = (self.pageScrollView.contentOffset.x + CGRectGetWidth(self.frame)/2)/CGRectGetWidth(self.frame);
        if (page != self.currentPage)
        {
            self.currentPage = page;
            [self selectItemInPage:self.currentPage];
            [self.pageScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.frame)*self.currentPage, 0) animated:YES];
        }
    }
    else if (scrollView == self)
    {
        
    }
    else if (scrollView == self.itemScrollView)
    {
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.pageScrollView) {
        int page = (self.pageScrollView.contentOffset.x + CGRectGetWidth(self.frame)/2)/CGRectGetWidth(self.frame);
        self.currentPage = page;
        [self.pageScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.frame)*self.currentPage, 0) animated:YES];
    }
    else if (scrollView == self)
    {
        
    }
    else if (scrollView == self.itemScrollView)
    {
        
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.pageScrollView) {
        int page = (self.pageScrollView.contentOffset.x + CGRectGetWidth(self.frame)/2)/CGRectGetWidth(self.frame);
        self.currentPage = page;
        [self.pageScrollView setContentOffset:CGPointMake(CGRectGetWidth(self.frame)*self.currentPage, 0) animated:YES];
    }
    else if (scrollView == self)
    {
        
    }
    else if (scrollView == self.itemScrollView)
    {
        
    }
}


@end
