//
//  CircleButtonView.m
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/15.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import "CircleButtonView.h"
#define RADIUS 45
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
@implementation CircleButtonView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:CGRectMake(frame.origin.x - 25,frame.origin.y - 70,RADIUS + 1,RADIUS + 1)]) {
        circleBackGround = [[UILabel alloc] initWithFrame:CGRectMake(0,0,RADIUS,RADIUS)];
        circleBackGround.backgroundColor = [UIColor colorWithRed:(116/255.0) green:(212/255.0) blue:(253/255.0) alpha:0.8];
        circleBackGround.layer.masksToBounds = YES;
        circleBackGround.layer.cornerRadius = circleBackGround.bounds.size.height/2;
        [self addSubview:circleBackGround];
        
        valueSlider = [[EFCircularSlider alloc] initWithFrame:CGRectMake(0, 0, RADIUS + 1, RADIUS + 1)];
        valueSlider.unfilledColor = [UIColor clearColor];//colorWithRed:23/255.0f green:47/255.0f blue:70/255.0f alpha:1.0f];
        valueSlider.filledColor = [UIColor colorWithRed:155/255.0f green:211/255.0f blue:156/255.0f alpha:1.0f];
        valueSlider.lineRadiusDisplacement = 1;
        valueSlider.lineWidth = 3;
        valueSlider.minimumValue = 0;
        valueSlider.maximumValue = 200;
        valueSlider.handleType = EFSemiTransparentWhiteCircle;
        valueSlider.userInteractionEnabled = false;
        
        double rads = DEGREES_TO_RADIANS(180);
        CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
        valueSlider.transform = transform;
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
-(void)setSensorvalue:(float)value
{
    [valueSlider setCurrentValue:value];
}
-(void)changeToForceHarder
{
    [self defaultColor];
}

-(void)changeToForceSlight
{
    
}




@end
