//
//  ViewController.m
//  takephoto
//
//  Created by Ankye Sheng on 2019/1/10.
//  Copyright © 2019 Ankye Sheng. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <Photos/Photos.h>
#include <CoreMotion/CoreMotion.h>
#import <CoreFoundation/CoreFoundation.h>
#import <GPUImage/GPUImage.h>
#import "GPUImageBeautyFilter.h"
#import "FTPopOverMenu.h"
#import "AFMInfoBanner.h"

extern "C"
{
    // 对Unity中的unityToIOS方法进行实现
    void unityToIOS(char* str){
        // Unity传递过来的参数
        NSLog(@"unity to iOS %s",str);
        [[ViewController sharedInstance] unity:[NSString stringWithUTF8String:str]];
    }
    void iosToUnity(const char* str){
        UnitySendMessage("ARCamera", "iosToUnity", str);
    }
}

 
@interface ViewController ()
{
    GPUImageStillCamera *camera;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageBeautyFilter *beautifulFilter;
    __weak IBOutlet GPUImageView *imageView;
    GPUImageMovieWriter *writer;
    NSURL *url;
    __block NSString *currentFilterCls;
}
@property (weak, nonatomic) IBOutlet UILabel *ylabel;
@property (weak, nonatomic) IBOutlet UILabel *xlabel;
@property (weak, nonatomic) IBOutlet UILabel *zlabel;
@property (weak, nonatomic) IBOutlet UILabel *rxlabel;
@property (weak, nonatomic) IBOutlet UILabel *rylabel;
@property (weak, nonatomic) IBOutlet UILabel *slabel;
@property (weak, nonatomic) IBOutlet UILabel *lslabel;
@property (weak, nonatomic) IBOutlet UILabel *lzlabel;
@property (weak, nonatomic) IBOutlet UILabel *lylabel;
@property (weak, nonatomic) IBOutlet UILabel *lxlabel;
@property (weak, nonatomic) IBOutlet UISlider *ryslider;
@property (weak, nonatomic) IBOutlet UISlider *rxslider;
@property (weak, nonatomic) IBOutlet UISlider *zslider;
@property (weak, nonatomic) IBOutlet UISlider *yslider;
@property (weak, nonatomic) IBOutlet UISlider *xslider;
@property (weak, nonatomic) IBOutlet UISlider *scaleslider;
- (IBAction)scaleCharacter:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *takeBtn;
@property (weak, nonatomic) IBOutlet UIButton *beautifulBtn;
@property (weak, nonatomic) IBOutlet UIStackView *settingView;
@property (weak, nonatomic) IBOutlet UISlider *lsslider;

- (IBAction)takePhotoAction:(id)sender;

- (IBAction)recordVideoAction:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UISlider *lzslider;

@property (weak, nonatomic) IBOutlet UISlider *lyslider;

@property (weak, nonatomic) IBOutlet UISlider *lxslider;

- (IBAction)switchFilterAction:(id)sender;

- (IBAction)resetCharactor:(id)sender;

- (IBAction)beautifulAction:(UIButton *)sender;

- (IBAction)lightRXAction:(id)sender;

- (IBAction)lightStrongAction:(id)sender;
- (IBAction)lightRYAction:(id)sender;
- (IBAction)lightRZAction:(id)sender;

- (IBAction)onXSliderChange:(id)sender;
- (IBAction)onYSliderChange:(id)sender;
- (IBAction)onZSliderChange:(id)sender;
- (IBAction)onRXSliderChange:(id)sender;
- (IBAction)onRYSliderChange:(id)sender;

@end

@implementation ViewController


static ViewController* _instance = nil;

+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+(void)showTips:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [AFMInfoBanner showAndHideWithText:text style:AFMInfoBannerStyleInfo];
    });
    
}

+(void)showErrorTips:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [AFMInfoBanner showAndHideWithText:text style:AFMInfoBannerStyleError];
    });
    
}

- (IBAction)loadCharacter:(id)sender {
    [self go];

    [FTPopOverMenu showForSender:sender
                   withMenuArray:@[@"正面", @"侧面", @"蹲", @"回头",@"侧面2",@"正面2",@"正面3",@"跳跃"]
                       doneBlock:^(NSInteger selectedIndex) {
                           
                           NSLog(@"done block. do something. selectedIndex : %ld", (long)selectedIndex);
                           int value = 0;
                           switch (selectedIndex) {
                               case 0:{
                                   value =0;
                                   break;
                               }
                               case 1:{
                                   value = 1;
                                   break;
                               }
                               case 2:{
                                   value = 2;
                                   break;
                               }
                               case 3:{
                                   value = 3;
                                   break;
                               }
                               case 4:{
                                   value = 4;
                                   break;
                               }
                               case 5:{
                                   value = 5;
                                   break;
                               }
                               case 6:{
                                   value = 6;
                                   break;
                               }
                               case 7:{
                                   value = 7;
                                   break;
                               }
                               default:
                                   break;
                           }
                           
                           NSString *str = [NSString stringWithFormat:@"A,1,%d",value];
                           const char* s = [str UTF8String];
                           iosToUnity(s);
                           
                           
                       } dismissBlock:^{
                           
                           NSLog(@"user canceled. do nothing.");
                           
                           //                           FTPopOverMenuConfiguration *configuration = [FTPopOverMenuConfiguration defaultConfiguration];
                           //                           configuration.allowRoundedArrow = !configuration.allowRoundedArrow;
                           
                       }];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    return [super viewWillAppear:animated];
    
}
- (void )unity:(NSString*) str {
 NSLog(@"unityToIOS  %@",str);
    NSArray *aArray = [str componentsSeparatedByString:@","];
    if(aArray ){
        NSString* name = aArray[0];
        if( [name isEqualToString:@"T"]){
            UIImage* img = [UIImage imageNamed:aArray[1]];
            [self saveImage:img];
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
   // [self checkCamera];

//
//    _Btn = [[UIButton alloc]initWithFrame:CGRectMake(40, SCREEN_HEIGHT-100, 80, 40)];
//    _Btn.backgroundColor = [UIColor blueColor];
//    [_Btn setTitle:@"开始" forState:UIControlStateNormal];
//    [_Btn addTarget:self action:@selector(go) forControlEvents:UIControlEventTouchDown];
//    [self.view addSubview:_Btn];
//
//
//
//    UITapGestureRecognizer *tap= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPress:)];
//    [_takeBtn addGestureRecognizer:tap];
//
//    UILongPressGestureRecognizer *longPress= [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
//    [_takeBtn addGestureRecognizer:longPress];
//
//    camera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
//    camera.outputImageOrientation = UIInterfaceOrientationPortrait;
////    camera.horizontallyMirrorFrontFacingCamera = YES;
////    camera.horizontallyMirrorRearFacingCamera = YES;
//
//    imageView.fillMode = kGPUImageFillModePreserveAspectRatio;
//
//    [self switchFilter:[[self filters].firstObject allValues].firstObject];
//
//    [camera startCameraCapture];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
  
}






-(void)checkCamera{

    _imagePicker = [[UIImagePickerController alloc] init];

    //检查摄像头权限
    NSString * mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authorizationStatus == AVAuthorizationStatusDenied) {
        //没有获得权限

        return;
    }
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePicker.showsCameraControls = NO;
    _imagePicker.toolbarHidden = YES;
    _imagePicker.navigationBarHidden = YES;
    _imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;

    //  _imagePicker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    //  [self presentViewController:self.imagePicker animated:YES completion:nil];
    //    [self.imagePicker.view setBounds:self.view.bounds];
    [self.view addSubview:self.imagePicker.view];

    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    float aspectRatio = 4.0/3.0;
    float scale = screenSize.height/screenSize.width * aspectRatio;
    _imagePicker.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);

}

-(void)go{
    
    //进入unity界面
//    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    [app showUnityWindow];
//    UnityPause(false);
    
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    // Do any additional setup after loading the view, typically from a nib.
    [app unityView].backgroundColor = [UIColor clearColor];
    [imageView addSubview:[app unityView]];
    
  
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [filter removeAllTargets];
    [camera removeAllTargets];
    [camera stopCameraCapture];
    camera.audioEncodingTarget = nil;
}

//屏幕方向
- (void)deviceOrientationDidChange:(NSNotification *)notify{
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    camera.outputImageOrientation = orientation;
}


- (IBAction)takePhotoAction:(UIButton*)sender {
//    [camera capturePhotoAsImageProcessedUpToFilter:filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
//        NSLog(@"processedImage %@",processedImage);
//        //runOnMainQueueWithoutDeadlocking(^{
//            [self saveImage:processedImage];
//        //});
//    }];
    
    NSString *str = [NSString stringWithFormat:@"T,1,%d",1];
    const char* s = [str UTF8String];
    iosToUnity(s);
}

- (IBAction)recordVideoAction:(UIButton *)sender {
    NSLog(@"start recording");
    //重新生产writer
    //Video path
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.mp4",[NSUUID UUID].UUIDString]];
    unlink([path UTF8String]);
    url = [NSURL fileURLWithPath:path];
    
    writer = [[GPUImageMovieWriter alloc] initWithMovieURL:url size:CGSizeMake(480.0, 640.0)];
    writer.encodingLiveVideo = YES;
    camera.audioEncodingTarget = writer;
    [filter removeAllTargets];
    [camera removeAllTargets];
    [filter addTarget:writer];
    [filter addTarget:imageView];
    [camera addTarget:filter];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->writer startRecording];
    });
}



- (void)saveImage:(UIImage *)image{
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } error:&error];
    
    [ViewController showTips:!error?@"保存成功":@"保存失败"];
    
   
}


- (IBAction)switchFilterAction:(id)sender {
    [self switchFilterActionSheet];
}

- (IBAction)resetCharactor:(id)sender {
  
    
    [FTPopOverMenu showForSender:sender
                   withMenuArray:@[@"调整参数", @"调整光线", @"调整焦点", @"重置",]
                      imageArray:@[
                                   [UIImage imageNamed:@"Pokemon_Go_04"],
                                   [UIImage imageNamed:@"ic_torch_on_2"],
                                   [UIImage imageNamed:@"ic_auto_focus_exposure"],
                                   [UIImage imageNamed:@"picBack"],
                                   ]
                       doneBlock:^(NSInteger selectedIndex) {
                           
                           NSLog(@"done block. do something. selectedIndex : %ld", (long)selectedIndex);
                           switch (selectedIndex) {
                               case 0:{
                                   [self.settingView setHidden:NO];
                                   [self.lightView setHidden:YES];
                                   break;
                               }
                               case 1:{
                                    [self.settingView setHidden:YES];
                                   [self.lightView setHidden:NO];
                                   break;
                               }
                               case 2:{
                                    [self.settingView setHidden:YES];
                                   [self.lightView setHidden:YES];
                                   break;
                               }
                               case 3:{
                                   [self.settingView setHidden:YES];
                                   [self.lightView setHidden:YES];
                                   NSString *str = [NSString stringWithFormat:@"C,7,%d",1];
                                   const char* s = [str UTF8String];
                                   iosToUnity(s);
                                   self.xslider.value = 0;
                                   [self setX:0];
                                   self.yslider.value = 0;
                                   [self setY:0];
                                   self.zslider.value = 0;
                                   [self setZ:0];
                                   self.rxslider.value = 0;
                                   [self setRX:0];
                                   self.ryslider.value = 0;
                                   [self setRY:0];
                                   self.scaleslider.value = 3.0;
                                    [self setS:3];
                                   self.lxslider.value = 45;
                                    [self setLX:45];
                                   self.lyslider.value = 90;
                                    [self setLY:90];
                                   self.lzslider.value = 90;
                                    [self setLZ:90];
                                   self.lsslider.value = 1.0;
                                    [self setLS:1];
                                  
                                   break;
                               }
                               default:
                                   break;
                           }
                          
                           
                       } dismissBlock:^{
                           
                           NSLog(@"user canceled. do nothing.");
                           
                           //                           FTPopOverMenuConfiguration *configuration = [FTPopOverMenuConfiguration defaultConfiguration];
                           //                           configuration.allowRoundedArrow = !configuration.allowRoundedArrow;
                           
                       }];
    
    

}





- (IBAction)onXSliderChange:(id)sender {
    UISlider *slider = (UISlider *)sender;
    float value = slider.value; // slider.value >0 ?0.1 : -0.1;
    NSString *str = [NSString stringWithFormat:@"C,1,%lf",value];
    const char* s = [str UTF8String];
    iosToUnity(s);
    [self setX:value];
}

-(void)setX:(float)value {
    self.xlabel.text = [NSString stringWithFormat:@"左右 %lf",value];
}
-(void)setY:(float)value {
    self.ylabel.text = [NSString stringWithFormat:@"上下 %lf",value];
}
-(void)setZ:(float)value {
    self.zlabel.text = [NSString stringWithFormat:@"前后 %lf",value];
}
-(void)setRX:(float)value {
    self.rxlabel.text = [NSString stringWithFormat:@"倾斜 %lf",value];
}
-(void)setRY:(float)value {
    self.rylabel.text = [NSString stringWithFormat:@"旋转 %lf",value];
}
-(void)setS:(float)value {
    self.slabel.text = [NSString stringWithFormat:@"缩放 %lf",value];
}
-(void)setLX:(float)value {
    self.lxlabel.text = [NSString stringWithFormat:@"x旋转 %lf",value];
}
-(void)setLY:(float)value {
    self.lylabel.text = [NSString stringWithFormat:@"y旋转 %lf",value];
}
-(void)setLZ:(float)value {
    self.lzlabel.text = [NSString stringWithFormat:@"z旋转 %lf",value];
}
-(void)setLS:(float)value {
    self.lslabel.text = [NSString stringWithFormat:@"强弱 %lf",value];
}


- (IBAction)onYSliderChange:(id)sender {
    UISlider *slider = (UISlider *)sender;
    float value = slider.value; // slider.value >0 ? 0.1 : -0.1;
    NSString *str = [NSString stringWithFormat:@"C,2,%lf",value];
    const char* s = [str UTF8String];
    iosToUnity(s);
    [self setY:value];

}
- (IBAction)onZSliderChange:(id)sender {
    UISlider *slider = (UISlider *)sender;
    float value = slider.value; // slider.value >0 ? 0.1 : -0.1;
    NSString *str = [NSString stringWithFormat:@"C,3,%lf",value];
    const char* s = [str UTF8String];
    iosToUnity(s);
    [self setZ:value];

}

- (IBAction)onRXSliderChange:(id)sender {
    UISlider *slider = (UISlider *)sender;
    float value = slider.value; // slider.value >0 ? 1 : -1;
    NSString *str = [NSString stringWithFormat:@"C,4,%lf",value];
    const char* s = [str UTF8String];
    iosToUnity(s);
    [self setRX:value];

}

- (IBAction)onRYSliderChange:(id)sender {
    UISlider *slider = (UISlider *)sender;
    float value = slider.value; // slider.value >0 ? 1 : -1;
    NSString *str = [NSString stringWithFormat:@"C,5,%lf",value];
    const char* s = [str UTF8String];
    iosToUnity(s);
    [self setRY:value];

}

- (IBAction)scaleCharacter:(id)sender {
    UISlider *slider = (UISlider *)sender;
    float value = slider.value; // slider.value >0 ? 1 : -1;
    NSString *str = [NSString stringWithFormat:@"C,6,%lf",value];
    const char* s = [str UTF8String];
    iosToUnity(s);
    [self setS:value];

}

- (IBAction)beautifulAction:(UIButton *)sender {
    if (!beautifulFilter) {
        beautifulFilter = [[GPUImageBeautyFilter alloc]init];
    }
    if (self.beautifulBtn.selected==NO) {
        [filter removeAllTargets];
        [camera removeAllTargets];
        [camera addTarget:beautifulFilter];
        [beautifulFilter addTarget:filter];
        [filter addTarget:imageView];
        self.beautifulBtn.selected = YES;
    } else {
        [filter removeAllTargets];
        [camera removeAllTargets];
        [camera addTarget:filter];
        [filter addTarget:imageView];
        self.beautifulBtn.selected = NO;
    }
}

- (IBAction)lightRXAction:(id)sender {
    UISlider *slider = (UISlider *)sender;
    float value = slider.value; // slider.value >0 ? 1 : -1;
    NSString *str = [NSString stringWithFormat:@"L,1,%lf",value];
    const char* s = [str UTF8String];
    iosToUnity(s);
    [self setLX:value];

}



- (IBAction)lightRYAction:(id)sender {
    UISlider *slider = (UISlider *)sender;
    float value = slider.value; // slider.value >0 ? 1 : -1;
    NSString *str = [NSString stringWithFormat:@"L,2,%lf",value];
    const char* s = [str UTF8String];
    iosToUnity(s);
    [self setLY:value];

}

- (IBAction)lightRZAction:(id)sender {
    UISlider *slider = (UISlider *)sender;
    float value = slider.value; // slider.value >0 ? 1 : -1;
    NSString *str = [NSString stringWithFormat:@"L,3,%lf",value];
    const char* s = [str UTF8String];
    iosToUnity(s);
    [self setLZ:value];

}

- (IBAction)lightStrongAction:(id)sender {
    UISlider *slider = (UISlider *)sender;
    float value = slider.value; // slider.value >0 ? 1 : -1;
    NSString *str = [NSString stringWithFormat:@"L,4,%lf",value];
    const char* s = [str UTF8String];
    iosToUnity(s);
    [self setLS:value];

}


//- (void)tapPress:(UITapGestureRecognizer *)sender{
//    if (sender.state==UIGestureRecognizerStateEnded) {
//        [self takePhotoAction:nil];
//    }
//}
//
//- (void)longPress:(UILongPressGestureRecognizer *)sender{
//    if (sender.state==UIGestureRecognizerStateBegan) {
//        [self recordVideoAction:nil];
//    } else if (sender.state==UIGestureRecognizerStateEnded||
//               sender.state==UIGestureRecognizerStateCancelled) {
//        [self endRecord:nil];
//    }
//}

- (void)switchFilterActionSheet{
    __block UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选取滤镜" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __block NSMutableArray *actions = [NSMutableArray array];
    [[self filters] enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:obj.allKeys.firstObject style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull act) {
            [self switchFilter:obj.allValues.firstObject];
        }];
        [actions addObject:action];
        [alert addAction:action];
    }];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [actions addObject:action];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)switchFilter:(NSString *)filterCls{
    if (!filterCls) return;
    [filter removeAllTargets];
    [camera removeAllTargets];
    filter = [[NSClassFromString(filterCls) alloc]init];
    if ([filterCls isEqualToString:@"GPUImageGaussianBlurFilter"]) {
        [(GPUImageGaussianBlurFilter *)filter setBlurRadiusInPixels:20];
    }
    if (self.beautifulBtn.selected) {
        [camera addTarget:beautifulFilter];
        [beautifulFilter addTarget:filter];
    } else {
        [camera addTarget:filter];
    }
    [filter addTarget:imageView];
    
    currentFilterCls = filterCls;
}

- (NSArray *)filters{
    return @[
             @{@"无":@"GPUImageFilter"},
             @{@"褐色":@"GPUImageSepiaFilter"},
             @{@"亮度平均值(黑白)":@"GPUImageAverageLuminanceThresholdFilter"},
             @{@"高斯模糊":@"GPUImageGaussianBlurFilter"},
             @{@"素描":@"GPUImageSketchFilter"},
             @{@"卡通效果(更细腻)":@"GPUImageSmoothToonFilter"},
             @{@"像素风":@"GPUImagePixellateFilter"},
             @{@"膨胀失真(鱼眼效果)":@"GPUImageBulgeDistortionFilter"},
             @{@"收缩失真(凹面镜)":@"GPUImagePinchDistortionFilter"},
             ];
}

- (NSString*)beatifulFilter{
    return @"GPUImageBeautifyFilter";
}



@end
