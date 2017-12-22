//
//  subVC2.m
//  Template Framework Project
//
//  Created by 陈威利 on 2017/12/18.
//  Copyright © 2017年 Daniele Galiotto - www.g8production.com. All rights reserved.
//

#import "subVC2.h"
#import "G8VideoScanController.h"
@interface subVC2 ()

@end

@implementation subVC2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 180, 40)];
    btn.center = self.view.center;
    [self.view addSubview:btn];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor colorWithRed:0.992 green:0.600 blue:0.161 alpha:1.00]];
    [btn setTitle:@"点击开始扫描" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(goNext) forControlEvents:UIControlEventTouchDown];
}

- (void)goNext{
    G8VideoScanController *vc = [G8VideoScanController new];

    [self presentViewController:vc animated:YES completion:nil];
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
