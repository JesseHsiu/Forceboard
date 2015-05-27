//
//  ZoomViewController.m
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/27.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import "ZoomViewController.h"
#define ZOOMTIME 0.5
#define SCALESIZE 1.5

@implementation ZoomViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    firstTap = false;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    orignCenter = keyboardView.center;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (!firstTap) {
        
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint touchLocation = [touch locationInView:self.view];
        
        
        CGAffineTransform transform = CGAffineTransformMakeScale(SCALESIZE, SCALESIZE);
        [UIView animateWithDuration:ZOOMTIME animations:^{
            keyboardView.transform = transform;
            keyboardView.center = CGPointMake(touchLocation.x, touchLocation.y);
        }];
    }
    else
    {
        [super touchesEnded:touches withEvent:event];
        CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
        [UIView animateWithDuration:ZOOMTIME animations:^{
            keyboardView.transform = transform;
            keyboardView.center = orignCenter;
        }];
    }
    
    firstTap = !firstTap;

}

@end
