//
//  mainViewController.h
//  Template Framework Project
//
//  Created by 陈威利 on 2017/12/18.
//  Copyright © 2017年 Daniele Galiotto - www.g8production.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "subVC1.h"
#import "subVC2.h"
@interface mainViewController : UIViewController
@property (nonatomic, strong)subVC1 *vc1;
@property (nonatomic, strong)subVC2 *vc2;
@property (nonatomic ,strong)UIViewController *currentVC;
@end
