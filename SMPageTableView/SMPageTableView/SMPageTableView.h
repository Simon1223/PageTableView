//
//  SMPageTableView.h
//  SMPageTableView
//
//  Created by huadong on 2016/12/16.
//  Copyright © 2016年 Simon.H. All rights reserved.
//

#import <UIKit/UIKit.h>



/*
 ** 自定义可切换的列表
 */

typedef NS_ENUM(NSInteger, SMPageItemType) {
    SMPageItemTypeMiddle  = 0,    //segmentBar居中布局
    SMPageItemTypeAverage = 1,    //segmentBar平均布局
};

typedef NS_ENUM(NSInteger, SMPageHeaderType) {
    SMPageHeaderTypePicture = 0,  //图片
    SMPageHeaderTypeVideo   = 1,  //视频
};

typedef void (^SMPageHeaderBlock)(NSString *contentURL , BOOL flag);
typedef void (^SMPageItemBlock)(id itemObject);

@interface SMPageTableView : UITableView

@property (nonatomic, assign) BOOL isShowHeaderView; //显示headerView
@property (nonatomic, assign) BOOL isShowItemView;   //显示分类
@property (nonatomic, assign) BOOL isShowFooterView; //显示footerVIew
@property (nonatomic, assign) SMPageHeaderType pageHeaderType; //头部风格

@property (nonatomic, strong) UIView *pageHeaderView;       //头部view 可添加其他控件
@property (nonatomic, strong) UIScrollView *itemScrollView; //item下面的scrollView
@property (nonatomic, strong) NSArray *items; //分组标题数组
@property (nonatomic, strong) NSMutableArray *dataArray; //列表数据
@property (nonatomic, assign) SMPageItemType pageItemType; //标题布局风格
@property (nonatomic, strong) UIView *itemView; //itemView界面
@property (nonatomic, assign) CGFloat itemViewHeight; //itemView的高度
@property (nonatomic, strong) UIColor *itemTitleSelectColor; //标题选中颜色
@property (nonatomic, strong) UIColor *itemTitleDeselectColor; //标题取消选中颜色
@property (nonatomic, strong) UIFont *itemTitleFont; //标题字体
@property (nonatomic, copy) SMPageItemBlock pageItemBlock;
@property (nonatomic, copy) SMPageHeaderBlock pageHeaderBlock;

@property (nonatomic, strong) UIScrollView *pageScrollView; //table下面的ScrollView
@property (nonatomic, strong) NSMutableArray *tableArray;  //pageView包含的tableView数组
@property (nonatomic, assign) NSInteger currentPage;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style items:(NSArray *)items itemViewHeight:(CGFloat)height;
- (UIView *)pageHeaderViewWithContent:(id)contentObject headerType:(SMPageHeaderType)type headerBlock:(SMPageHeaderBlock)block;

- (void)loadItemBlock:(SMPageItemBlock)block;


@end
