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
    [super viewDidAppear:animated];
    NSLog(@"%f, %f", [dKey convertPoint:dKey.center toView:self.view].x,[dKey convertPoint:dKey.center toView:self.view].y);
    [keyboardView setTranslatesAutoresizingMaskIntoConstraints:NO];
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
}

-(void)handleSwipe:(UISwipeGestureRecognizer *)swipeGestureRecognizer{
    
    if (swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight ) {
        isCurrentLeft = YES;
        middleLineConstraint.constant = -228;
        [keySequence addObject:@"->"];
        
        NSMutableArray *array_x = [[NSMutableArray alloc] init];
        NSMutableArray *array_y = [[NSMutableArray alloc] init];
        
        for (int i = 0; i< [pathRecordtmp count]; i++) {
            [array_x addObject:[pathRecordtmp objectAtIndex:i][0]];
            [array_y addObject:[pathRecordtmp objectAtIndex:i][1]];
        }
        NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:array_x, @"xs", array_y, @"ys", @"right", @"type", nil];
        [pathRecordBeforeNext addObject:dict];
        [pathRecordtmp removeAllObjects];
        
    }
    else if (swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        [keySequence addObject:@"<-"];
        isCurrentLeft = NO;
        middleLineConstraint.constant = -136;
        
        NSMutableArray *array_x = [[NSMutableArray alloc] init];
        NSMutableArray *array_y = [[NSMutableArray alloc] init];
        
        for (int i = 0; i< [pathRecordtmp count]; i++) {
            [array_x addObject:[pathRecordtmp objectAtIndex:i][0]];
            [array_y addObject:[pathRecordtmp objectAtIndex:i][1]];
        }
        NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:array_x, @"xs", array_y, @"ys", @"left", @"type", nil];
        [pathRecordBeforeNext addObject:dict];
        [pathRecordtmp removeAllObjects];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.view setNeedsDisplay];
    }];
    [movedKey removeAllObjects];
    isTouching = false;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == keyboardView && [keyPath isEqualToString:@"bounds"]) {
        // do your stuff, or better schedule to run later using performSelector:withObject:afterDuration:
    }
}

@end
