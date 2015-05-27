//
//  SplitViewController.m
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/27.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import "SplitViewController.h"

@implementation SplitViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    isCurrentLeft = YES;
    
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [keyboardView addGestureRecognizer:swipeRight];
    [keyboardView addGestureRecognizer:swipeLeft];
    [keyboardView addObserver:self forKeyPath:@"bounds" options:0 context:nil];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    orignCenter = keyboardView.center;
    leftCenter =CGPointMake(197, orignCenter.y);
    rightCenter =CGPointMake(111, orignCenter.y);
    
    
    
    [super viewDidAppear:animated];
    NSLog(@"%f, %f", [dKey convertPoint:dKey.center toView:self.view].x,[dKey convertPoint:dKey.center toView:self.view].y);
    
    CGAffineTransform transform = CGAffineTransformMakeScale(1.65, 1);
    [UIView animateWithDuration:0.2 animations:^{
        keyboardView.transform = transform;
        keyboardView.center = leftCenter;
    }];
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
    [super touchesEnded:touches withEvent:event];
//    [keyboardView removeFromSuperview];
//    [self.view addSubview:keyboardView];
    
    
    [self performSelector:@selector(adjustPosition) withObject:self afterDelay:0.001];
    
}


-(void)handleSwipe:(UISwipeGestureRecognizer *)swipeGestureRecognizer{
    
    if (swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight ) {
        isCurrentLeft = YES;
        
        [UIView animateWithDuration:0.2 animations:^{
            keyboardView.center = leftCenter;
        }];
        
    }
    else if (swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        isCurrentLeft = NO;
        [UIView animateWithDuration:0.2 animations:^{
            keyboardView.center = rightCenter;
        }];
    }
    
    [self performSelector:@selector(adjustPosition) withObject:self afterDelay:0.001];
    [movedKey removeAllObjects];
    isTouching = false;
}
-(void)adjustPosition
{
    if (isCurrentLeft) {
        keyboardView.center = leftCenter;
    }
    else
    {
        keyboardView.center = rightCenter;
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == keyboardView && [keyPath isEqualToString:@"bounds"]) {
        // do your stuff, or better schedule to run later using performSelector:withObject:afterDuration:
    }
}

@end
