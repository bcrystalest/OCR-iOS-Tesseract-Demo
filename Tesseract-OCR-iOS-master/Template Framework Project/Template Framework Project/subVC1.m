//
//  subVC1.m
//  Template Framework Project
//
//  Created by 陈威利 on 2017/12/18.
//  Copyright © 2017年 Daniele Galiotto - www.g8production.com. All rights reserved.
//

#import "subVC1.h"

@interface subVC1 ()
@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong)NSTimer *timer;
@end

@implementation subVC1

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 120, 120)];
    imageView.center = self.view.center;
    [self.view addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"ford111"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView = imageView;

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    self.timer = [NSTimer timerWithTimeInterval:8.0 target:self selector:@selector(goPageNext) userInfo:nil repeats:NO];
    sleep(1.5);
    [self goPageNext];
}

- (void)goPageNext{
    if (_block) {
        _block();
    }
}
                  
- (void)viewWillDisappear:(BOOL)animated{
    [_timer invalidate];
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
