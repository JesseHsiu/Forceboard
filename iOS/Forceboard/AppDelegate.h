//
//  AppDelegate.h
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/11.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SerialGATT.h"
#import <CHCSVParser.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CHCSVWriter *writer;

-(void)showAlertToNotifyUser;
-(void)changeCSVFileName:(id)viewController;
@end

