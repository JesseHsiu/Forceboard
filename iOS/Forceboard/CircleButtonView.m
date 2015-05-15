//
//  CircleButtonView.m
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/15.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import "CircleButtonView.h"
#define RADIUS 45
@implementation CircleButtonView
-(instancetype)init
{

    if (self = [super initWithFrame:CGRectMake(0,0,1.5*RADIUS,1.5*RADIUS)]) {
        circleBackGround = [[UILabel alloc] initWithFrame:CGRectMake(0,0,1.5*RADIUS,1.5*RADIUS)];
        [self defaultColor];
        [self addSubview:circleBackGround];
        
        valueSlider = [[EFCircularSlider alloc] initWithFrame:CGRectMake(0,0,1.5*RADIUS,1.5*RADIUS)];
        valueSlider.unfilledColor = [UIColor colorWithRed:23/255.0f green:47/255.0f blue:70/255.0f alpha:1.0f];
        valueSlider.filledColor = [UIColor colorWithRed:155/255.0f green:211/255.0f blue:156/255.0f alpha:1.0f];
        valueSlider.lineWidth = 8;
        valueSlider.minimumValue = 0;
        valueSlider.maximumValue = 200;
        [self addSubview:valueSlider];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:CGRectMake(frame.origin.x,frame.origin.y,1.5*RADIUS,1.5*RADIUS)]) {
        circleBackGround = [[UILabel alloc] initWithFrame:CGRectMake(0,0,1.5*RADIUS,1.5*RADIUS)];
        [self defaultColor];
        [self addSubview:circleBackGround];
        
        
        
        valueSlider = [[EFCircularSlider alloc] initWithFrame:CGRectMake(frame.origin.x +1 ,frame.origin.y - 6,1.5*RADIUS,1.5*RADIUS)];
        valueSlider.unfilledColor = [UIColor colorWithRed:23/255.0f green:47/255.0f blue:70/255.0f alpha:1.0f];
        valueSlider.filledColor = [UIColor colorWithRed:155/255.0f green:211/255.0f blue:156/255.0f alpha:1.0f];
        valueSlider.lineWidth = 5;
        valueSlider.minimumValue = 0;
        valueSlider.maximumValue = 200;
        [self addSubview:valueSlider];
    }
    return self;
}


-(void)defaultColor
{
    circleBackGround.text = @"●";
    circleBackGround.transform = CGAffineTransformMakeTranslation(0.0f, -RADIUS/6);
    circleBackGround.textAlignment = NSTextAlignmentCenter;
    circleBackGround.backgroundColor = [UIColor clearColor];
    circleBackGround.textColor = [UIColor colorWithRed:(116/255.0) green:(212/255.0) blue:(253/255.0) alpha:0.8];
    circleBackGround.font = [UIFont systemFontOfSize:2*RADIUS];
    circleBackGround.center = self.center;
}

-(void)changeToForceHarder
{
    [self defaultColor];
}

-(void)changeToForceSlight
{
    
}




@end
