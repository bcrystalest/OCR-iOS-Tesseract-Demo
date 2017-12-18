//
//  G8ScanView.h
//  Template Framework Project
//
//  Created by 陈威利 on 2017/11/20.
//  Copyright © 2017年 Daniele Galiotto - www.g8production.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G8ScanView : UIView

@property (nonatomic,assign) CGRect facePathRect;
@property (nonatomic,assign) CGRect targetBounds;
@property (nonatomic,strong) UIView *targetView;
@end
