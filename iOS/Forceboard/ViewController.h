//
//  ViewController.h
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/11.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SerialGATT.h"

@interface ViewController : UIViewController<BTSmartSensorDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *discoveredBLEs;
    IBOutlet UITableView *tableview;
    IBOutlet UIButton *searchBtn;
    IBOutlet UILabel *outputText;
    
    NSMutableArray *movedKey;
    NSArray *gonnaSetSensorValue;
    NSArray *currentSensorValue;
    BOOL upperCase;
    
    
    NSArray *calibrateValues;
    
}
@property (strong, nonatomic) SerialGATT *sensor;
-(void) scanTimer:(NSTimer *)timer;
@end

