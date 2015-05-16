//
//  CircleButtonView.h
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/15.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EFCircularSlider.h>

@interface CircleButtonView : UIView
{
    UILabel *circleBackGround;
    EFCircularSlider *valueSlider;
    
    UILabel *textLabel;

}
-(void)setSensorvalue:(float)value;
-(void)setText:(NSString*)string AndValue:(float)value;
-(void)setText:(NSString*)string;
-(void)changeToForceHarder;
-(void)changeToForceSlight;
@end
