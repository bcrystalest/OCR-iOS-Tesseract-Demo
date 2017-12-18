//
//  G8PhotoScanViewController.h
//  Template Framework Project
//
//  Created by 陈威利 on 2017/11/20.
//  Copyright © 2017年 Daniele Galiotto - www.g8production.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TesseractOCR/TesseractOCR.h>
@interface G8PhotoScanViewController : UIViewController<G8TesseractDelegate,UIImagePickerControllerDelegate,
UINavigationControllerDelegate>
typedef void (^block)(UIImage *);
@property (nonatomic,copy)block finishiBlock;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

