//
//  AppDelegate.h
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/11.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SerialGATT.h"
#import <CHCSVParser.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,BTSmartSensorDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SerialGATT *bleSerial;
@property (strong, nonatomic) NSArray *gonnaSetSensorValue;
@property (strong, nonatomic) NSArray *currentSensorValue;
@property (strong, nonatomic) NSMutableArray *discoveredBLEs;
@property (strong, nonatomic) CHCSVWriter *writer;
@property (strong, nonatomic) NSArray *calibrateValues;
@property (nonatomic, readonly, getter=isBleConnected) BOOL bleConnected;

-(void)startScanningBLE;
-(void)stopScanning;
-(void)showAlertToNotifyUser;
@end

