//
//  AppDelegate.h
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/11.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SerialGATT.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(void)showAlertToNotifyUser:(void (^)(void))callbackBlock;
-(void)changeCSVFileName:(id)viewController;
-(NSString*)currentFilePath;
@end

