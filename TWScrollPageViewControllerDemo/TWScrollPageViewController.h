//
//  TWScrollPageViewController.h
//  TWScrollPageViewControllerDemo
//
//  Created by 抬头看见柠檬树 on 2017/2/10.
//  Copyright © 2017年 csip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TWScrollPageViewController : UIViewController

// 子控制器数组
@property (nonatomic, strong) NSMutableArray<UIViewController *> *childVCArray;

+ (void)setupChildVCs:(NSMutableArray *)childVCs;

@end
