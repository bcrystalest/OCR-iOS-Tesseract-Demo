//
//  G8VideoScanController.h
//  Template Framework Project
//
//  Created by 陈威利 on 2017/12/14.
//  Copyright © 2017年 Daniele Galiotto - www.g8production.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TesseractOCR/TesseractOCR.h>

@interface G8VideoScanController : UIViewController<G8TesseractDelegate,UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

@end
