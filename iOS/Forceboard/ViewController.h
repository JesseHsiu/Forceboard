//
//  ViewController.h
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/11.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SerialGATT.h"
#import "CircleButtonView.h"
#import "TaskLabel.h"
typedef  enum{
    SlightTouch = 0,
    HeavyTouch
} TouchModes;

@interface ViewController : UIViewController<BTSmartSensorDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *discoveredBLEs;
    IBOutlet UITableView *tableview;
    IBOutlet UIButton *searchBtn;
    IBOutlet UILabel *outputText;
    IBOutlet UILabel *WPMLabel;
    IBOutlet UIView *keyboardView;

    IBOutlet TaskLabel *taskLabel;
    IBOutlet UIButton *nextTaskBtn;
    
    NSMutableArray *movedKey;
    NSArray *gonnaSetSensorValue;
    NSArray *currentSensorValue;
    BOOL upperCase;
    NSNumber *thresholdValue;
    
    
    NSArray *calibrateValues;
    
    
    BOOL isTouching;
    
    NSDate *startTime;
    
    NSString *orignTaskText;
    
}
@property (strong, nonatomic) SerialGATT *sensor;
@property (nonatomic)  TouchModes touchModes;
-(void) scanTimer:(NSTimer *)timer;
@end

