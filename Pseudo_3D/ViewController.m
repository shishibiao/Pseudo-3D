//
//  ViewController.m
//  Pseudo_3D
//
//  Created by ssb on 2019/10/17.
//  Copyright © 2019 心之所向，必是那未来世界的美好. All rights reserved.
//

#import "ViewController.h"
#import "CameraViewController.h"

#define AppWidth                      [[UIScreen mainScreen] bounds].size.width
#define AppHeight                     [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *Title = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, AppWidth, 20)];
    Title.text = @"心之所向，必是那未来世界的美好";
    Title.textAlignment = NSTextAlignmentCenter;
    Title.font = [UIFont systemFontOfSize:16];
    Title.textColor = [UIColor blackColor];
    [self.view addSubview:Title];
    
    UIButton *Pseudo_3D_Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    Pseudo_3D_Btn.frame = CGRectMake((AppWidth - 100)/2, 200, 100, 40);
    Pseudo_3D_Btn.layer.borderWidth = 1;
    [Pseudo_3D_Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    Pseudo_3D_Btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    Pseudo_3D_Btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [Pseudo_3D_Btn setTitle:@"伪3D" forState:UIControlStateNormal];
    [Pseudo_3D_Btn addTarget:self action:@selector(pseudoclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Pseudo_3D_Btn];
    
}

-(void)pseudoclick:(UIButton *)btn{
    CameraViewController *CameraVC = [[CameraViewController alloc]init];
    [self presentViewController:CameraVC animated:YES completion:nil];
}

@end
