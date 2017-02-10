//
//  TWScrollPageViewController.m
//  TWScrollPageViewControllerDemo
//
//  Created by 抬头看见柠檬树 on 2017/2/10.
//  Copyright © 2017年 csip. All rights reserved.
//

#import "TWScrollPageViewController.h"

#define screen_w [UIScreen mainScreen].bounds.size.width
#define screen_h [UIScreen mainScreen].bounds.size.height

@interface TWScrollPageViewController ()<UIScrollViewDelegate>

// 标题scrollView
@property (nonatomic, strong) UIScrollView *titleScrollView;

// 内容scrollView
@property (nonatomic, strong) UIScrollView *contentScrollView;

// 标题按钮数组
@property (nonatomic, strong) NSMutableArray<UIButton *> *titleButtons;

// 记录选中标题按钮
@property (nonatomic, weak) UIButton *selectButton;

@property (nonatomic, assign) BOOL isSuc;

@end

@implementation TWScrollPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 1.设置标题scrollView
    [self.view addSubview:self.titleScrollView];
    
    // 2.设置内容scrollView
    [self.view addSubview:self.contentScrollView];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_isSuc) {
        // 3.添加所有子控制器
        [self setupAllChildViewController];
        
        // 4.设置所有标题
        [self setupAllTitleButton];
        
        _isSuc = true;
    }
   
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger i = scrollView.contentOffset.x / screen_w;
    
    UIButton *titleButton = self.titleButtons[i];
    
    [self titleClick:titleButton];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger leftI = scrollView.contentOffset.x / screen_w;
    NSInteger rightI = 1 + leftI;
    
    UIButton *leftBtn = self.titleButtons[leftI];
    NSInteger count = self.titleButtons.count;
    
    UIButton *rightBtn;
    if (rightI < count) {
        rightBtn = self.titleButtons[rightI];
    }
    
    // 0~1 => 1~1.3
    CGFloat scaleR = scrollView.contentOffset.x / screen_w;
    scaleR -= leftI;
    
    CGFloat scaleL = 1 - scaleR;
    
    leftBtn.transform = CGAffineTransformMakeScale(scaleL * 0.3 + 1, scaleL * 0.3 + 1);
    rightBtn.transform = CGAffineTransformMakeScale(scaleR * 0.3 + 1, scaleR * 0.3 + 1);
    
    UIColor *leftColor = [UIColor colorWithRed:scaleL green:0 blue:0 alpha:1];
    UIColor *rightColor = [UIColor colorWithRed:scaleR green:0 blue:0 alpha:1];
    [leftBtn setTitleColor:leftColor forState:UIControlStateNormal];
    [rightBtn setTitleColor:rightColor forState:UIControlStateNormal];
}

#pragma mark - 设置所有标题
- (void)setupAllTitleButton
{
    NSInteger count = self.childVCArray.count;
    CGFloat btnW = 80;
    CGFloat btnH = self.titleScrollView.bounds.size.height;
    CGFloat btnX = 0;
    for (NSInteger i = 0; i < count; i++) {
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        titleButton.tag = i + 10086;
        UIViewController *vc = self.childVCArray[i];
        [titleButton setTitle:vc.title
                     forState:UIControlStateNormal];
        btnX = i * btnW;
        titleButton.frame = CGRectMake(btnX, 0, btnW, btnH);
        [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        // 监听按钮点击
        [titleButton addTarget:self
                        action:@selector(titleClick:)
              forControlEvents:UIControlEventTouchUpInside];
        
        [self.titleButtons addObject:titleButton];
        
        if (i == 0) {
            // 默认点击第一个标题
            [self titleClick:titleButton];
        }
        
        [self.titleScrollView addSubview:titleButton];
    }
    
    // 设置标题scrollView的滚动范围
    self.titleScrollView.contentSize = CGSizeMake(count * btnW, 0);
    self.titleScrollView.showsHorizontalScrollIndicator = NO;
    
    // 设置内容scrollView的滚动范围
    self.contentScrollView.contentSize = CGSizeMake(count * screen_w, 0);
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
}

// 处理按钮点击
- (void)titleClick:(UIButton *)button
{
    NSInteger i = button.tag - 10086;
    
    // 标题颜色变成红色
    [self selButton:button];
    
    // 把对应子控制器view添加上去
    [self setupChildVCView:i];
    
    // 内容滚动到对应的位置
    CGFloat offsetX = i * screen_w;
    self.contentScrollView.contentOffset = CGPointMake(offsetX, 0);
}

// 选中标题
- (void)selButton:(UIButton *)button
{
    // 当选中下一个标题时，恢复上一个标题的样式
    _selectButton.transform = CGAffineTransformIdentity;
    [_selectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    // 设置标题选中样式
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    // 标题居中
    [self setupTitleButtonCenter:button];
    
    // 标题按钮字体变形（标题缩放即可实现）
    button.transform = CGAffineTransformMakeScale(1.3, 1.3);
    
    _selectButton = button;
}

// 标题居中
- (void)setupTitleButtonCenter:(UIButton *)button
{
    // 实际上就是修改titleScrollView的contentOffset
    CGFloat offsetX = button.center.x - screen_w * 0.5;
    
    if (offsetX < 0) {
        // 最左边的按钮不用居中
        offsetX = 0;
    }
    
    //最大偏移量
    CGFloat maxOffsetX = self.titleScrollView.contentSize.width - screen_w;
    
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    
    [self.titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

// 添加一个子控制器的View
- (void)setupChildVCView:(NSInteger)i
{
    UIViewController *vc = self.childVCArray[i];
    if (vc.view.superview) {
        //如果一个子控制器已经添加过了，那么它的view一定有superview
        return;
    }
    
    CGFloat x = i * screen_w;
    vc.view.frame = CGRectMake(x, 0, screen_w, self.contentScrollView.bounds.size.height);
    [self.contentScrollView addSubview:vc.view];
}


#pragma mark - 添加所有子控制器
- (void)setupAllChildViewController
{
    for (UIViewController *childVC in self.childVCArray) {
        [self addChildViewController:childVC];
    }
}

#pragma mark - 懒加载
- (UIScrollView *)titleScrollView
{
    if (_titleScrollView) {
        return _titleScrollView;
    }
    
    // 验证是否有navigationController或navigationBar是否隐藏
    CGFloat y = self.navigationController.navigationBarHidden ? 20 : 64;
    
    UIScrollView *titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, screen_w, 44)];
    
    _titleScrollView = titleScrollView;
    return _titleScrollView;
}

- (UIScrollView *)contentScrollView
{
    if (_contentScrollView) {
        return _contentScrollView;
    }
    
    CGFloat y = CGRectGetMaxY(self.titleScrollView.frame);
    UIScrollView *contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, screen_w, screen_h - y)];
    contentScrollView.pagingEnabled = YES;
    contentScrollView.bounces = NO;
    contentScrollView.delegate = self;
    
    _contentScrollView = contentScrollView;
    return _contentScrollView;
}

-(NSMutableArray<UIViewController *> *)childVCArray
{
    if (_childVCArray) {
        return _childVCArray;
    }
    
    _childVCArray = [NSMutableArray array];
    return _childVCArray;
}

-(NSMutableArray<UIButton *> *)titleButtons
{
    if (_titleButtons) {
        return _titleButtons;
    }
    
    _titleButtons = [NSMutableArray array];
    return _titleButtons;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
