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
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.bleSerial = [[SerialGATT alloc] init];
    [self.bleSerial setup];
    self.bleSerial.delegate = self;
    self.discoveredBLEs = [[NSMutableArray alloc]init];
    self.userNameSaved = false;
    
    
    self.calibrateValues = @[[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:0.0f]];
    
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



#pragma mark - HMSoftSearching
-(void)scanTimer:(NSTimer *)timer
{
    [self stopScanning];
}
-(void)stopScanning
{
    [self.bleSerial stopScan];
    [self.discoveredBLEs removeAllObjects];
}



#pragma mark - HMSoftSensorDelegate
-(void) peripheralFound:(CBPeripheral *)peripheral
{
    if (![self.discoveredBLEs containsObject:peripheral]) {
        [self.discoveredBLEs addObject:peripheral];
    }
}
-(void) serialGATTCharValueUpdated: (NSString *)UUID value: (NSData *)data
{
    NSString *value = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    if ([[value componentsSeparatedByString:@"/"] count] != 5) {
        return;
    }
    else{
        self.gonnaSetSensorValue = [value componentsSeparatedByString:@"/"];
        [self performSelector:@selector(changecurrentValue) withObject:nil afterDelay:0.02];
    }
}
-(void)changecurrentValue
{
    self.currentSensorValue = self.gonnaSetSensorValue;
}
-(void) setConnect
{
    
    
    
}
-(void) setDisconnect
{
}


-(void)alertTextFieldDidChange:(UITextField*)textfield
{
    NSString* userid = textfield.text;
    [self changeCSVFileName:userid];
    self.userNameSaved = true;
    
}


-(void)changeCSVFileName:(NSString*)name
{
    
    NSString *tempFileName;
    if ([self.window.rootViewController isKindOfClass:[ViewController class]]) {
        tempFileName = [NSString stringWithFormat:@"%@_force.csv",name];
    }
    else if ([self.window.rootViewController isKindOfClass:[ZoomViewController class]])
    {
        tempFileName = [NSString stringWithFormat:@"%@_zoom.csv",name];
    }
    else if ([self.window.rootViewController isKindOfClass:[SplitViewController class]])
    {
        tempFileName = [NSString stringWithFormat:@"%@_split.csv",name];
    }
    else if ([self.window.rootViewController isKindOfClass:[QWERTYViewController class]])
    {
        tempFileName = [NSString stringWithFormat:@"%@_qwerty.csv",name];
    }
    
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *tempFile = [docsPath stringByAppendingPathComponent:tempFileName];
    NSOutputStream *output = [NSOutputStream outputStreamToFileAtPath:tempFile append:YES];
    self.writer = [[CHCSVWriter alloc] initWithOutputStream:output encoding:NSUTF8StringEncoding delimiter:','];
}

-(void)startScanningBLE
{

    if ([self.bleSerial activePeripheral]) {
        if (self.bleSerial.activePeripheral.state == CBPeripheralStateConnected) {
            [self.bleSerial.manager cancelPeripheralConnection:self.bleSerial.activePeripheral];
            self.bleSerial.activePeripheral = nil;
        }
    }
    
    if ([self.bleSerial peripherals]) {
        self.bleSerial.peripherals = nil;
    }
    
    self.bleSerial.delegate = self;
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    
    [self.bleSerial findHMSoftPeripherals:10];
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
