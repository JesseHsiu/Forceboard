//
//  ZoomViewController.m
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/27.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import "ZoomViewController.h"

@implementation ZoomViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    firstTap = false;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (!firstTap) {
        CGAffineTransform transform = CGAffineTransformMakeScale(1.5, 1.5);
        [UIView animateWithDuration:0.5 animations:^{
            keyboardView.transform = transform;
            
            keyboardView.center = CGPointMake(100, 100);
        }];
    }
    else
    {
        CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
        [UIView animateWithDuration:0.5 animations:^{
            keyboardView.transform = transform;
        }];
    }
    
    firstTap = !firstTap;

}

@end
