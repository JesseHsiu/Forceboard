//
//  ViewController.h
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/11.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleButtonView.h"
#import "TaskLabel.h"
typedef  enum{
    SlightTouch = 0,
    HeavyTouch
} TouchModes;

@interface ViewController : UIViewController<UITextViewDelegate>
{

    IBOutlet UITextView *outputText;
    IBOutlet UILabel *WPMLabel;
    IBOutlet UIView *keyboardView;

    IBOutlet TaskLabel *taskLabel;
    IBOutlet UIButton *nextTaskBtn;
    
    UILabel *currentTaskNumberText;
    int currentTaskNumber;
    
    NSMutableArray *movedKey;
    BOOL upperCase;
    NSNumber *thresholdValue;
    
    BOOL isTouching;
    
    NSDate *startTime;
    
    NSString *orignTaskText;
    NSMutableArray *forceData;
    
    NSMutableArray *keySequence;
    
}
@property (nonatomic)  TouchModes touchModes;
@end

