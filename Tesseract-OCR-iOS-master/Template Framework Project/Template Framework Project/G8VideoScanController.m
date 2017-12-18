//
//  Camera.h
//  VideoPlayback
//
//  Created by Mac on 14-10-31.
//  Copyright (c) 2014年 fly. All rights reserved.
//
#define kScreenBounds   [UIScreen mainScreen].bounds
#define kScreenWidth  kScreenBounds.size.width*1.0
#define kScreenHeight kScreenBounds.size.height*1.0
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "G8VideoScanController.h"
#import "G8ScanView.h"
@interface G8VideoScanController() <AVCaptureVideoDataOutputSampleBufferDelegate,G8TesseractDelegate>
@property (nonatomic, strong)AVCaptureSession *captureSession;
@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong)G8ScanView *IDCardScaningView;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong)AVCaptureVideoDataOutput *captureOutput;
@property(nonatomic, strong)id cameraQueue;
//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation G8VideoScanController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device  error:nil];
    self.captureOutput = [[AVCaptureVideoDataOutput alloc] init];

    //    丢弃最后视频帧
    _captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    dispatch_queue_t queue = dispatch_queue_create("cameraQueue", NULL);
    
    // self要遵守 AVCaptureVideoDataOutputSampleBufferDelegate 协议
    [_captureOutput setSampleBufferDelegate:self queue:queue];
    _cameraQueue = queue;
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [_captureOutput setVideoSettings:videoSettings];
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:captureInput];
    [self.captureSession addOutput:_captureOutput];
    [self.captureSession startRunning];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    self.previewLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    
    self.IDCardScaningView  = [[G8ScanView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.IDCardScaningView];
    
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(40, 310,150 , 150)];
    self.imageView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.imageView];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    
//    UIImage *image= [UIImage imageNamed:@"image_sample.jpg"];
//    [self recognizeImageWithTesseract:image];

}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
    {
        ////            把 CMSampleBufferRef 缓冲区转换成 CVImageBufferRef
//        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
//        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//
//        //    根据 CVImageBufferRef 生成 CGContextRef
//        CVPixelBufferLockBaseAddress(imageBuffer,0);
//        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
//        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
//        size_t width = CVPixelBufferGetWidth(imageBuffer);
//        size_t height = CVPixelBufferGetHeight(imageBuffer);
//        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//        CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
//
//        //    CGContextRef --> CGImageRef
//        CGImageRef newImage = CGBitmapContextCreateImage(newContext);
        
        //    在imageView上显示预览图像
         __weak __typeof(self) weakself= self;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            UIImage *image = [weakself imageFromSampleBuffer:sampleBuffer];
            
//            image. = UIImageOrientationDown;
//            UIImage *newImg = [self fixOrientation:image];
            UIImage *newImg = [self scaleAndRotateImage:image];
            UIImage *newImg2 = [weakself reSizeImage:newImg toSize:[UIScreen mainScreen].bounds.size];
            UIImage *newImg3 = [weakself getSmallImage:newImg2];
            weakself.imageView.image = newImg3;
            [weakself recognizeImageWithTesseract:newImg3];
        });
}


//CMSampleBufferRef转NSImage
-(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    // 释放context和颜色空间
    CGContextRelease(context); CGColorSpaceRelease(colorSpace);
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    return (image);
}

//image缩小
-(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImage *lastImage = [self imageByCroppingWithImage:scaledImage];

    return lastImage;   //返回的就是已经改变的图片
}

//剪裁图片
-(UIImage*)imageByCroppingWithImage:(UIImage*)myImage{
    
    CGRect rect = CGRectMake(0,0,200,50);
    
    CGImageRef imageRef = myImage.CGImage;
    CGImageRef imagePartRef=CGImageCreateWithImageInRect(imageRef,rect);
    UIImage * cropImage=[UIImage imageWithCGImage:imagePartRef];
    CGImageRelease(imagePartRef);
    
    return cropImage;
}



//方形裁剪
-(UIImage *)getSmallImage:(UIImage *)image
{
    //IDCardScaningView
    
    //    CGFloat widthRation = self.view.frame.size.width/self.image
    
    UIImage *newImg = image;
    //    UIImage *newImg = [self fixOrientation:self.image];
    //
    //    CGFloat origX = (self.circularFrame.origin.x - _imageView.frame.origin.x) / rationScale;
    //    CGFloat origY = (self.circularFrame.origin.y - _imageView.frame.origin.y) / rationScale;
    //    CGFloat oriWidth = self.circularFrame.size.width / rationScale;
    //    CGFloat oriHeight = self.circularFrame.size.height / rationScale;
    CGRect myRect = CGRectMake(self.IDCardScaningView.targetView.frame.origin.x+30, self.IDCardScaningView.targetView.frame.origin.y, self.IDCardScaningView.targetView.frame.size.width - 60, self.IDCardScaningView.targetView.frame.size.height);
    //    myRect.size.width = myRect.size.width - 15;
    CGImageRef imageRef = CGImageCreateWithImageInRect(newImg.CGImage, myRect);
    
    UIGraphicsBeginImageContext(myRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myRect, imageRef);
    UIImage * clipImage = [UIImage imageWithCGImage:imageRef];
    UIGraphicsEndImageContext();
    
    CGImageRelease(imageRef);
    
    return clipImage;
}


-(void)recognizeImageWithTesseract:(UIImage *)image
{
    // Animate a progress activity indicator
    //    [self.activityIndicator startAnimating];
    
    // Create a new `G8RecognitionOperation` to perform the OCR asynchronously
    // It is assumed that there is a .traineddata file for the language pack
    // you want Tesseract to use in the "tessdata" folder in the root of the
    // project AND that the "tessdata" folder is a referenced folder and NOT
    // a symbolic group in your project
    [_captureOutput setSampleBufferDelegate:nil queue:_cameraQueue];
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"eng"];
    
    // Use the original Tesseract engine mode in performing the recognition
    // (see G8Constants.h) for other engine mode options
    operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
    
    // Let Tesseract automatically segment the page into blocks of text
    // based on its analysis (see G8Constants.h) for other page segmentation
    // mode options
    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeAutoOnly;
    
    // Optionally limit the time Tesseract should spend performing the
    // recognition
    //operation.tesseract.maximumRecognitionTime = 1.0;
    
    // Set the delegate for the recognition to be this class
    // (see `progressImageRecognitionForTesseract` and
    // `shouldCancelImageRecognitionForTesseract` methods below)
    operation.delegate = self;
    
    // Optionally limit Tesseract's recognition to the following whitelist
    // and blacklist of characters
    //operation.tesseract.charWhitelist = @"01234";
    //operation.tesseract.charBlacklist = @"56789";
    
    // Set the image on which Tesseract should perform recognition
    operation.tesseract.image = image;
    
    // Optionally limit the region in the image on which Tesseract should
    // perform recognition to a rectangle
    //operation.tesseract.rect = CGRectMake(20, 20, 100, 100);
    
    // Specify the function block that should be executed when Tesseract
    // finishes performing recognition on the image
    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract) {
        // Fetch the recognized text
        NSString *recognizedText = tesseract.recognizedText;
        
        NSLog(@"%@", recognizedText);
        
        // Remove the animated progress activity indicator
        //        [self.activityIndicator stopAnimating];
        recognizedText = [recognizedText stringByReplacingOccurrencesOfString:@" " withString:@""];
        recognizedText = [recognizedText stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSString *newString = [NSString stringWithFormat:@"%@",recognizedText];
        NSString *regex = @"^[0-9]+$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        BOOL isMatch  = [pred evaluateWithObject:newString];
        if (isMatch) {
            //        if ([newString containsString:@":"]) {
            // Spawn an alert with the recognized text
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OCR Result"
                                                            message:recognizedText
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            alert.tag = 101;
            [alert show];
        }else{
             [_captureOutput setSampleBufferDelegate:self queue:_cameraQueue];
        }
    };
    
    // Display the image to be recognized in the view

    // Finally, add the recognition operation to the queue
    [self.operationQueue addOperation:operation];
    [self cleanOneQueue:operation];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 101) {
        [self cleanAllQueue];
        [_captureOutput setSampleBufferDelegate:self queue:_cameraQueue];
    }
    
}


- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    NSLog(@"progress: %lu", (unsigned long)tesseract.progress);
}

/**
 *  This function is part of Tesseract's delegate. It will be called
 *  periodically as the recognition happens so you can cancel the recogntion
 *  prematurely if necessary.
 *
 *  @param tesseract The `G8Tesseract` object performing the recognition.
 *
 *  @return Whether or not to cancel the recognition.
 */
- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to cancel recognition prematurely
}


- (UIImage *)changeImageHeightLight:(UIImage *)originalImage{
    UIImage *myImage = originalImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *superImage = [CIImage imageWithCGImage:myImage.CGImage];
    CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
    [lighten setValue:superImage forKey:kCIInputImageKey];
    
    // 修改亮度   -1---1   数越大越亮
    [lighten setValue:@(0.5) forKey:@"inputBrightness"];
    
    // 修改饱和度  0---2
    [lighten setValue:@(0.5) forKey:@"inputSaturation"];
    
    // 修改对比度  0---4
    [lighten setValue:@(2.5) forKey:@"inputContrast"];
    CIImage *result = [lighten valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[superImage extent]];
    
    // 得到修改后的图片
    myImage = [UIImage imageWithCGImage:cgImage];
    
    // 释放对象
    CGImageRelease(cgImage);
    return myImage;
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
    
}

-(UIImage *)fixOrientation:(UIImage *)image
{
//    if (image.imageOrientation == UIImageOrientationUp)
//        return image;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    UIImageOrientation orientation = UIImageOrientationRight;
    
    switch (orientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (orientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (orientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (void)cleanOneQueue:(NSOperation *)operation{
    for (G8RecognitionOperation *newOperation in self.operationQueue.operations) {
        if (operation != newOperation) {
            [operation cancel];
        }
    }
}

- (void)cleanAllQueue{
    
    for (G8RecognitionOperation *operation in self.operationQueue.operations) {
        [operation cancel];
    }

}
- (UIImage *)scaleAndRotateImage:(UIImage *)image  {
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    CGFloat boundHeight;
    
    boundHeight = bounds.size.height;
    bounds.size.height = bounds.size.width;
    bounds.size.width = boundHeight;
    transform = CGAffineTransformMakeScale(-1.0, 1.0);
    transform = CGAffineTransformRotate(transform, M_PI / 2.0); //use angle/360 *MPI
    
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
    
}


@end
