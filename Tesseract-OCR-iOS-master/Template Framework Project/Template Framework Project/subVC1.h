//
//  subVC1.h
//  Template Framework Project
//
//  Created by 陈威利 on 2017/12/18.
//  Copyright © 2017年 Daniele Galiotto - www.g8production.com. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^choicePageBlock)(void);

@interface subVC1 : UIViewController
@property (nonatomic, copy) choicePageBlock block;
@end
