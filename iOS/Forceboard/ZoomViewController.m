//
//  ZoomViewController.m
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/27.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import "ZoomViewController.h"
#define ZOOMTIME 0.2
#define SCALESIZE 2.0

@implementation ZoomViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    firstTap = false;
    tmpTap = [[NSMutableArray alloc] init];
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
    if (isTouching) {
        if (!firstTap) {
            
            UITouch *touch = [[event allTouches] anyObject];
            CGPoint touchLocation = [touch locationInView:keyboardView];
            
            
            
            [tmpTap addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:touchLocation.x],[NSNumber numberWithFloat:touchLocation.y], nil]];
            
            CGPoint touchALLLocation = [touch locationInView:self.view];
//            CGRect screenRect = [[UIScreen mainScreen] bounds];
//            CGFloat screenWidth = screenRect.size.width;
//            CGFloat screenHeight = screenRect.size.height;
            
            CGAffineTransform transform = CGAffineTransformMakeScale(SCALESIZE, SCALESIZE);
            [UIView animateWithDuration:ZOOMTIME animations:^{
                keyboardView.center = CGPointMake(orignCenter.x - (touchALLLocation.x - orignCenter.x) * 1.2, orignCenter.y - (touchALLLocation.y - orignCenter.y)* 1.2 );
                keyboardView.transform = transform;
                
            }];
            
            
        }
        else
        {
            
            
            
            if ([movedKey count] == 0)
            {
                [tmpTap removeAllObjects];
            }
            else{
                UITouch *touch = [[event allTouches] anyObject];
                CGPoint touchLocation = [touch locationInView:keyboardView];
                [tmpTap addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:touchLocation.x],[NSNumber numberWithFloat:touchLocation.y], nil]];
                
                
                [zoomPositionRecord addObject:[tmpTap copy]];
                [tmpTap removeAllObjects];
            }
            
            [super touchesEnded:touches withEvent:event];
            
            CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
            [UIView animateWithDuration:ZOOMTIME animations:^{
                keyboardView.transform = transform;
                keyboardView.center = orignCenter;
            }];
            
        }
        
        firstTap = !firstTap;
    }
    
    isTouching = false;
    
}

@end
