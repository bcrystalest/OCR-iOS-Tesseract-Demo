//
//  G8ViewController.m
//  Template Framework Project
//
//  Created by Daniele on 14/10/13.
//  Copyright (c) 2013 Daniele Galiotto - www.g8production.com.
//  All rights reserved.
//

#import "G8ViewController.h"
#import "G8PhotoScanViewController.h"
#import "G8VideoScanController.h"
@interface G8ViewController ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end


/**
 *  For more information about using `G8Tesseract`, visit the GitHub page at:
 *  https://github.com/gali8/Tesseract-OCR-iOS
 */
@implementation G8ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Create a queue to perform recognition operations
    self.operationQueue = [[NSOperationQueue alloc] init];
}

-(void)recognizeImageWithTesseract:(UIImage *)image
{
    // Animate a progress activity indicator
    [self.activityIndicator startAnimating];

    // Create a new `G8RecognitionOperation` to perform the OCR asynchronously
    // It is assumed that there is a .traineddata file for the language pack
    // you want Tesseract to use in the "tessdata" folder in the root of the
    // project AND that the "tessdata" folder is a referenced folder and NOT
    // a symbolic group in your project
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
        [self.activityIndicator stopAnimating];

        // Spawn an alert with the recognized text
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OCR Result"
                                                        message:recognizedText
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    };
    
    // Display the image to be recognized in the view
    self.imageToRecognize.image = operation.tesseract.thresholdedImage;

    // Finally, add the recognition operation to the queue
    [self.operationQueue addOperation:operation];
}

/**
 *  This function is part of Tesseract's delegate. It will be called
 *  periodically as the recognition happens so you can observe the progress.
 *
 *  @param tesseract The `G8Tesseract` object performing the recognition.
 */
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

- (IBAction)openCamera:(id)sender
{
//    UIImagePickerController *imgPicker = [UIImagePickerController new];
//    imgPicker.delegate = self;
//    imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    imgPicker.allowsEditing = NO;
    
//    UIImageView *redView = [UIImageView new];
//    redView.backgroundColor = [UIColor grayColor];
//    redView.frame = self.view.bounds;
//    UIView *clearView = [UIView new];
//    clearView.backgroundColor = [UIColor clearColor];
//    clearView.frame = CGRectMake(self.view.bounds.size.width / 2 - 80, 80, 160, 30);
//    [redView insertSubview:clearView aboveSubview:redView];
//    clearView.layer.borderWidth = 1.0f;
//    clearView.layer.borderColor = [UIColor redColor].CGColor;
////    [imgPicker.view addSubview:redView];
//    imgPicker.cameraOverlayView = redView;//3.0以后可以直接设置cameraOverlayView为overlay
//    imgPicker.wantsFullScreenLayout = YES;
//    CAShapeLayer *imgTakeLayer = [CAShapeLayer layer];
//    imgTakeLayer.position = imgPicker.view.layer.position;
//    CGFloat width = self.view.bounds.size.width - 60;
//    imgTakeLayer.bounds = (CGRect){CGPointZero, {width, width * 0.374}};
//    imgTakeLayer.cornerRadius = 15;
//    imgTakeLayer.borderColor = [UIColor whiteColor].CGColor;
//    imgTakeLayer.borderWidth = 1.5;
//    [imgPicker.view.layer addSublayer:imgTakeLayer];
//
//    // 最里层镂空
//    UIBezierPath *transparentRoundedRectPath = [UIBezierPath bezierPathWithRoundedRect:imgTakeLayer.frame cornerRadius:imgTakeLayer.cornerRadius];
//
//    // 最外层背景
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:imgPicker.view.frame];
//    [path appendPath:transparentRoundedRectPath];
//    [path setUsesEvenOddFillRule:YES];
//
//    CAShapeLayer *fillLayer = [CAShapeLayer layer];
//    fillLayer.path = path.CGPath;
//    fillLayer.fillRule = kCAFillRuleEvenOdd;
//    fillLayer.fillColor = [UIColor blackColor].CGColor;
//    fillLayer.opacity = 0.6;
//
//    [imgPicker.view.layer addSublayer:fillLayer];
    
    
    
//    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//    {
//        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//        [self presentViewController:imgPicker animated:YES completion:nil];
//    }
//    G8PhotoScanViewController *vc = [G8PhotoScanViewController new];
    
    G8VideoScanController *vc = [G8VideoScanController new];
//    vc.finishiBlock = ^(UIImage *image) {
//        [self recognizeImageWithTesseract:image];
//    };
    [self presentViewController:vc animated:YES completion:nil];
}




- (IBAction)recognizeSampleImage:(id)sender {
    [self recognizeImageWithTesseract:[UIImage imageNamed:@"image_sample.jpg"]];
}

- (IBAction)clearCache:(id)sender
{
    [G8Tesseract clearCache];
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    UIImage *changeImage=[UIImage imageWithCGImage:image.CGImage
                                             scale:1.0
                                       orientation:UIImageOrientationLeft];
//    NSLog(@"%f",self.view.bounds.size.height);
//    NSLog(@"%f",self.view.bounds.size.width);
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self recognizeImageWithTesseract:changeImage];
//    UIImageView *view = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 80, 80, 160, 160)];
//    view.image = newImg;
//    [self.view addSubview:view];
    
}
@end
