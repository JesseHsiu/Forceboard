//
//  AppDelegate.m
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/11.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "ZoomViewController.h"
#import "SplitViewController.h"
#import "QWERTYViewController.h"

@interface AppDelegate ()
@property (nonatomic,assign) BOOL userNameSaved;
@property (nonatomic,strong) NSString* userID;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    self.bleSerial = [[SerialGATT alloc] init];
//    [self.bleSerial setup];
//    self.bleSerial.delegate = self;
    self.userNameSaved = false;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)alertTextFieldDidChange:(UITextField*)textfield
{
    self.userID = textfield.text;
    self.userNameSaved = true;
    [self changeCSVFileName:self.window.rootViewController];
}


-(void)changeCSVFileName:(id)viewController
{
    if (self.userNameSaved == FALSE) {
        return;
    }
    
    NSString *tempFileName;
    if ([viewController isKindOfClass:[QWERTYViewController class]])
    {
        tempFileName = [NSString stringWithFormat:@"%@_qwerty.csv",self.userID];
    }
    else if ([viewController isKindOfClass:[ZoomViewController class]])
    {
        tempFileName = [NSString stringWithFormat:@"%@_zoom.csv",self.userID];
    }
    else if ([viewController isKindOfClass:[SplitViewController class]])
    {
        tempFileName = [NSString stringWithFormat:@"%@_split.csv",self.userID];
    }
    else if ([viewController isKindOfClass:[ViewController class]]) {
        tempFileName = [NSString stringWithFormat:@"%@_force.csv",self.userID];
    }
    
    
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *tempFile = [docsPath stringByAppendingPathComponent:tempFileName];
    NSOutputStream *output = [NSOutputStream outputStreamToFileAtPath:tempFile append:YES];
    self.writer = [[CHCSVWriter alloc] initWithOutputStream:output encoding:NSUTF8StringEncoding delimiter:','];
}

-(void)showAlertToNotifyUser
{
    if (self.userNameSaved == true) {
        return;
    }
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"UserID"
                                          message:@"Please Enter User ID to save CSV file"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"userid";
         [textField addTarget:self
                       action:@selector(alertTextFieldDidChange:)
             forControlEvents:UIControlEventEditingDidEnd];
     }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         // do destructive stuff here
                                                     }];
    
    [alertController addAction:okAction];
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}
@end
