//
//  CameraViewController.m
//  Pseudo_3D
//
//  Created by ssb on 2019/10/17.
//  Copyright © 2019 心之所向，必是那未来世界的美好. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AudioToolbox/AudioToolbox.h>

#define AppWidth                      [[UIScreen mainScreen] bounds].size.width
#define AppHeight                     [[UIScreen mainScreen] bounds].size.height

@interface CameraViewController ()<UIGestureRecognizerDelegate,AVCapturePhotoCaptureDelegate>{
    CGRect oldFrame;    //保存图片原来的大小
    CGRect largeFrame;  //确定图片放大最大的程度
}
//使用相机或者麦克风实时采集音视频数据流
//AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureSession *session;
//输入端口
@property (nonatomic, strong) AVCaptureDeviceInput *DeviceInput;
//输出端口 iOS10之前
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
//照片输出流 iOS10 的新API，不仅支持静态图，还支持Live Photo等
@property (nonatomic, strong) AVCapturePhotoOutput *photoOutput;
@property (nonatomic, strong) AVCapturePhotoSettings *photoSettings;
//相机拍摄预览图层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

@property(nonatomic,strong) UIImageView *imageView;
@property(nonatomic,strong) UIImage *Newimage;
@property(nonatomic,strong) UIImage *Photoimage;

@property(nonatomic,strong) UIImage *photopImage;

@property(nonatomic) CGFloat lastRotation;

@property(nonatomic) CGFloat lastdegree;

@end

@implementation CameraViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.session) {
        [self.session startRunning];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    if (self.session) {
        [self.session stopRunning];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"拍照";
    self.view.backgroundColor = [UIColor clearColor];
    //自定义相机
    [self Customcamera];
}

#pragma mark - 自定义相机
-(void)Customcamera{
    //初始化
    _session = [[AVCaptureSession alloc]init];
    //设置分辨率
//    _session.sessionPreset = AVCaptureSessionPreset1280x720;
    
    //1.先查询是否授权使用硬件设备
    //2.获取指定摄像头的位置
    //3。直接获取输入设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //初始化设备输入对象，获取输入数据
    NSError *error = nil;
    _DeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:device error:&error];
    if (error) {
        NSLog(@"错误 ：%@",error.localizedDescription);
    }
    //初始化设备输出对象，获取输出数据
    //判断系统版本
    if (@available(iOS 10.0,*)) {
        //创建图像输出
        _photoOutput = [[AVCapturePhotoOutput  alloc]init];
        //链接输入会话
        if ([_session canAddInput:_DeviceInput]) {
            [_session addInput:_DeviceInput];
        }
        //链接输出会话
        if ([self.session canAddOutput:_photoOutput]) {
            [self.session addOutput:_photoOutput];
        }
    }else{
        //创建图像输出
        NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
        _stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
        [_stillImageOutput setOutputSettings:outputSettings];
        //链接输入会话
        if ([_session canAddInput:_DeviceInput]) {
            [_session addInput:_DeviceInput];
        }
        //链接输出会话
        if ([_session canAddOutput:_stillImageOutput]) {
            [_session addOutput:_stillImageOutput];
        }
    }
    //相机拍摄预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.previewLayer.frame = CGRectMake(0,0,AppWidth ,AppHeight);
    self.previewLayer.videoGravity = AVLayerVideoGravityResize;
    self.previewLayer.contentsScale = [UIScreen mainScreen].scale;
    self.previewLayer.backgroundColor = [[UIColor blackColor]CGColor];
    self.view.layer.masksToBounds = YES;
    
    [self.view.layer addSublayer:self.previewLayer];
    
    //创建相机下面自定义视图
    [self createCusphototV];
}

-(void)createCusphototV
{
    UIView *navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, AppWidth, 60)];
    navigationBar.backgroundColor = [UIColor clearColor];
    navigationBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:navigationBar];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, 7, 50, 50);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [navigationBar addSubview:backBtn];
    
    CGFloat viewH = 140;
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, AppHeight-viewH, AppWidth, viewH)];
    downView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:downView];
    //加上相机按钮和其他的自定义按钮
    UIButton* photoButotn = [[UIButton alloc] init];
    [photoButotn setTitle:@"拍照" forState:UIControlStateNormal];
    [photoButotn addTarget:self action:@selector(SavePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [downView addSubview:photoButotn];
    photoButotn.frame = CGRectMake((AppWidth-62)/2, 40, 62,62);

    //在view上添加一个ImageView
    UIImageView *image = [[UIImageView alloc] init];
    image.image = [UIImage imageNamed:@"timg.png"];
    image.frame = CGRectMake(0, 0, 128, 128);
    self.imageView = image;
    self.imageView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.imageView setUserInteractionEnabled:YES];
    oldFrame = self.imageView.frame;
    largeFrame = CGRectMake(0 - AppWidth, 0 - AppHeight, 3 * oldFrame.size.width, 3 * oldFrame.size.height);
    
    //添加捏合手势识别器，changeImageSize:方法实现图片的放大与缩小
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeImageSize:)];
    [self.view addGestureRecognizer:pinchRecognizer];
    
    //添加拖动手势识别器，panGestureDetected:方法实现图片的拖动
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDetected:)];
    [panGestureRecognizer setDelegate:self];
    [_imageView addGestureRecognizer:panGestureRecognizer];
    
    [self.view addSubview:self.imageView];
}


#pragma mark - 中心图片手势
//放大与缩小
-(void)changeImageSize:(UIPinchGestureRecognizer *)recognizer
{
    CGRect frame = self.imageView.frame;
    
    //监听两手指滑动的距离，改变imageView的frame
    frame.size.width = recognizer.scale*128;
    frame.size.height = recognizer.scale*128;
    self.imageView.frame = frame;
    if (self.imageView.frame.size.width < oldFrame.size.width)
    {
        self.imageView.frame = oldFrame;
        //让图片无法缩得比原图小
    }
    if (self.imageView.frame.size.width > 3 * oldFrame.size.width)
    {
        self.imageView.frame = largeFrame;
    }
    //保证imageView中心不动
    self.imageView.center =CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
}

//拖动
- (void)panGestureDetected:(UIPanGestureRecognizer *)recognizer
{
    UIGestureRecognizerState state = [recognizer state];
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        [recognizer.view setTransform:CGAffineTransformTranslate(recognizer.view.transform, translation.x, translation.y)];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    }
}

#pragma mark - 拍照
-(void)SavePhoto:(UIButton *)button
{
    AVCaptureConnection *conntion = nil;
    //进行拍照保存图片
    if (@available(iOS 10.0,*)){
        _photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecJPEG}];
        [_photoOutput capturePhotoWithSettings:_photoSettings delegate:self];
    }else{
        conntion = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        if (!conntion) {
            NSLog(@"拍照失败!");
            return;
        }
        [_stillImageOutput captureStillImageAsynchronouslyFromConnection:conntion completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (imageDataSampleBuffer == nil) {
                return ;
            }
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            _Newimage = [UIImage imageWithData:imageData];
            [self Dophoto];
        }];
    }

}


-(void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error{
    NSData *data = photo.fileDataRepresentation;
    _Newimage = [UIImage imageWithData:data];
    [self Dophoto];
}


-(UIImage*)captureView: (UIView *)theView
{
    CGRect rect = theView.frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context =UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

-(void)Dophoto
{
    NSLog(@"---%.2f|%.2f|%.2f|%.2f",_imageView.frame.origin.x,_imageView.frame.origin.y,_imageView.frame.size.width,_imageView.frame.size.height);
    _Photoimage = [self captureView:_imageView];
    NSLog(@"---%.2f|%.2f",_Photoimage.size.width,_Photoimage.size.height);
    NSLog(@"---%.2f|%.2f",_Newimage.size.width,_Newimage.size.height);
    
    UIGraphicsBeginImageContext(_Newimage.size);
    //image1
    [_Newimage drawInRect:CGRectMake(0, 0, _Newimage.size.width, _Newimage.size.height)];
    //image2
    [_Photoimage drawInRect:CGRectMake(_imageView.frame.origin.x * 3,_imageView.frame.origin.y * 3, _Photoimage.size.width *3, _Photoimage.size.height * 3)];

    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _photopImage = resultingImage;

    UIView *viewb = [[UIView alloc]init];
    viewb.frame = self.view.frame;
    viewb.backgroundColor = [UIColor blackColor];
    [self.view addSubview:viewb];
    UIImageView *imagev = [[UIImageView alloc] initWithImage:resultingImage];
    imagev.contentMode = UIViewContentModeScaleAspectFit;
    imagev.frame = CGRectMake(0, 0, AppWidth, AppHeight);
    [viewb addSubview:imagev];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, 7, 50, 50);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [viewb addSubview:backBtn];
}


#pragma mark - 返回
-(void)goBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
