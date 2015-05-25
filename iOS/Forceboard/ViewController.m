//
//  ViewController.m
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/11.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import "ViewController.h"
#import "KeysBtnView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CalculateErrorRate.h"
#import "KeyPressStatistic.h"
#import <CHCSVParser.h>
#define THERSHOLD 200
//use CircleView
#define CircleView 0


@interface ViewController ()
#if CircleView
@property CircleButtonView* circleView;
#endif
@property CalculateErrorRate* errorCalculator;
@property KeyPressStatistic* keysStatistic;
@property CHCSVWriter *writer;
@property NSString* userid;

@end

@implementation ViewController
@synthesize sensor;
@synthesize touchModes = _touchModes;
- (void)viewDidLoad {
    [super viewDidLoad];
    sensor = [[SerialGATT alloc] init];
    [sensor setup];
    sensor.delegate = self;
    
    discoveredBLEs = [[NSMutableArray alloc]init];
    movedKey = [[NSMutableArray alloc]init];
    
    upperCase= false;
    calibrateValues = [[NSArray alloc]initWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:0.0f] ,nil];
    
    [self addSwipeRecognizers];
    
    outputText.minimumScaleFactor = 0.5;
    outputText.adjustsFontSizeToFitWidth = YES;
    
    //error rate
//    char correctString[] = "the quick brown fox";
//    char inputString[] = "the quick brown foxxx";
    _errorCalculator = [[CalculateErrorRate alloc ]init];

//    float errorRate = (float)[_errorCalculator LevenshteinDistance:inputString andCorrect:correctString]/(float)MAX(strlen(correctString), strlen(inputString));
//    NSLog(@"%f", errorRate);
    //key press statistic
    _keysStatistic = [[KeyPressStatistic alloc] init];

}
-(void)dealloc
{
    [_writer closeStream];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)scanHMSoftDevices:(id)sender {
    
    //UI stuff
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [tableview setAlpha:1.0];
    [UIView commitAnimations];
    
    if ([sensor activePeripheral]) {
        if (sensor.activePeripheral.state == CBPeripheralStateConnected) {
            [sensor.manager cancelPeripheralConnection:sensor.activePeripheral];
            sensor.activePeripheral = nil;
        }
    }
    
    if ([sensor peripherals]) {
        sensor.peripherals = nil;
    }
    
    sensor.delegate = self;
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    
    [sensor findHMSoftPeripherals:10];
}

#pragma mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [discoveredBLEs count];

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = ((CBPeripheral *)[discoveredBLEs objectAtIndex:indexPath.row]).name;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    sensor.activePeripheral = [discoveredBLEs objectAtIndex:row];
    [sensor connect:sensor.activePeripheral];
    [self stopScanning];
    
    //UI stuff
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [tableview setAlpha:0];
    [searchBtn setAlpha:0];
    [UIView commitAnimations];
}

#pragma mark - HMSoftSearching
-(void)scanTimer:(NSTimer *)timer
{
    [self stopScanning];
}
-(void)stopScanning
{
    [sensor stopScan];
    [discoveredBLEs removeAllObjects];
}

#pragma mark - HMSoftSensorDelegate
-(void) peripheralFound:(CBPeripheral *)peripheral
{
    if (![discoveredBLEs containsObject:peripheral]) {
        [discoveredBLEs addObject:peripheral];
    }
    [tableview reloadData];
}
-(void) serialGATTCharValueUpdated: (NSString *)UUID value: (NSData *)data
{
    NSString *value = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    if ([[value componentsSeparatedByString:@"/"] count] != 5) {
        return;
    }
    else{
        gonnaSetSensorValue = [value componentsSeparatedByString:@"/"];
        [self performSelector:@selector(changecurrentValue) withObject:nil afterDelay:0.02];
    }
}
-(void)changecurrentValue
{
    currentSensorValue = gonnaSetSensorValue;
}
-(void) setConnect
{
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
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}
-(void) setDisconnect
{
}

#pragma mark - HMSoftSendingFunction
-(void)sendStringToArduino:(NSString*)string{
    NSData *data = [string dataUsingEncoding:[NSString defaultCStringEncoding]];
    if(data.length > 20)
    {
        int i = 0;
        while ((i + 1) * 20 <= data.length) {
            NSData *dataSend = [data subdataWithRange:NSMakeRange(i * 20, 20)];
            [sensor write:sensor.activePeripheral data:dataSend];
            i++;
        }
        i = data.length % 20;
        if(i > 0)
        {
            NSData *dataSend = [data subdataWithRange:NSMakeRange(data.length - i, i)];
            [sensor write:sensor.activePeripheral data:dataSend];
        }
        
    }else
    {
        [sensor write:sensor.activePeripheral data:data];
    }
}

#pragma mark - Touch Event
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    isTouching = true;
    self.touchModes = SlightTouch;
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
    for (UIView *view in self.view.subviews)
    {
        if ([view isMemberOfClass:[KeysBtnView class]] &&
            CGRectContainsPoint(view.frame, touchLocation) && view!= [movedKey lastObject])
        {
            [movedKey addObject:view];
        }
    }
    [self updateThreshold];
    if ([movedKey count] == 0) {
        return;
    }
    
    #if CircleView
    if (CGRectContainsPoint(keyboardView.frame, touchLocation)) {
        _circleView = [[CircleButtonView alloc]initWithFrame:CGRectMake(touchLocation.x,touchLocation.y, 100, 100)];
        [self updateCircleValue];
        [self.view addSubview:_circleView];
    }
    #endif
    
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
    for (UIView *view in self.view.subviews)
    {
        if ([view isMemberOfClass:[KeysBtnView class]] &&
            CGRectContainsPoint(view.frame, touchLocation) && view!= [movedKey lastObject])
        {
            [movedKey addObject:view];
        }
    }
    if ([movedKey count] == 0) {
        return;
    }
    
    #if CircleView
    if (CGRectContainsPoint(keyboardView.frame, touchLocation)) {
        
        if (!_circleView) {
            _circleView = [[CircleButtonView alloc]initWithFrame:CGRectMake(touchLocation.x,touchLocation.y, 100, 100)];
            [self.view addSubview:_circleView];
            [self updateCircleValue];
        }
        else
        {
            [_circleView setFrame:CGRectMake(touchLocation.x - 25,touchLocation.y - 70, _circleView.bounds.size.width, _circleView.bounds.size.height)];
        }

        [_circleView setAlpha:1.0f];
    }
    else
    {
        [_circleView setAlpha:0.0f];
    }
    #endif
    
    
    

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    isTouching = false;
    
    #if CircleView
    [_circleView removeFromSuperview];
    _circleView = nil;
    #endif
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    for (UIView *view in self.view.subviews)
    {
        if ([view isMemberOfClass:[KeysBtnView class]] &&
            CGRectContainsPoint(view.frame, touchLocation) && view!= [movedKey lastObject])
        {
            [movedKey addObject:view];
        }
    }
    
    if ([movedKey count] == 0) {
        return;
    }

    [taskLabel cleanNext];
    KeysBtnView *keybtn = (KeysBtnView*)[movedKey lastObject];
    NSArray *containkeys = [keybtn.titleLabel.text componentsSeparatedByString:@" "];
    
    if (self.touchModes == SlightTouch) {
        if ([containkeys[0] isEqualToString:@"_space"]) {
            outputText.text = [NSString stringWithFormat:@"%@%@",outputText.text,@" "];
        }
        else
        {
            outputText.text = [NSString stringWithFormat:@"%@%@",outputText.text,[self uplowerCasingString:containkeys[0]]];
        }
    }
    else
    {
        if ([containkeys[1] isEqualToString:@"delete"]) {
            if ([outputText.text length] == 0) {
                return;
            }
            outputText.text = [outputText.text substringToIndex:[outputText.text length]-1];
        }
        else
        {
            outputText.text = [NSString stringWithFormat:@"%@%@",outputText.text,[self uplowerCasingString:containkeys[1]]];
        }
    }
    self.touchModes = SlightTouch;
    upperCase = false;
    [movedKey removeAllObjects];
    
    
    for (UIView *view in self.view.subviews)
    {
        if ([view isMemberOfClass:[KeysBtnView class]])
        {
            [(KeysBtnView*)view setTitle:[[(KeysBtnView*)view currentTitle] lowercaseString] forState:UIControlStateNormal];
        }
    }
    
    
    if ([taskLabel.text length]<= [outputText.text length]) {
        [nextTaskBtn setEnabled:YES];
    }
}
#pragma mark - SwipeGesture
-(void)handleSwipeGesture:(UISwipeGestureRecognizer *)swipeGestureRecognizer{
    #if CircleView
    [_circleView removeFromSuperview];
    _circleView = nil;
    #endif
    switch (swipeGestureRecognizer.direction) {
        case UISwipeGestureRecognizerDirectionRight:
            outputText.text = [NSString stringWithFormat:@"%@%@",outputText.text,@" "];
            [taskLabel cleanNext];
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            if ([outputText.text length] == 0) {
                return;
            }
            outputText.text = [outputText.text substringToIndex:[outputText.text length]-1];
            [taskLabel backforwad];
            break;
        case UISwipeGestureRecognizerDirectionUp:
            upperCase = true;
            for (UIView *view in self.view.subviews)
            {
                if ([view isMemberOfClass:[KeysBtnView class]])
                {
                    [(KeysBtnView*)view setTitle:[[(KeysBtnView*)view currentTitle] uppercaseString] forState:UIControlStateNormal];
                }
            }
            
            break;
        case UISwipeGestureRecognizerDirectionDown:
            break;
            
        default:
            break;
    }
}

-(void)addSwipeRecognizers
{
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionRight;
    
    [outputText addGestureRecognizer:swipeRight];
    [outputText addGestureRecognizer:swipeLeft];
    [outputText addGestureRecognizer:swipeUp];
    [outputText addGestureRecognizer:swipeDown];
}

#pragma mark - Button Action
- (IBAction)ClearUILabel:(id)sender {
    [taskLabel backToOrigin];
    outputText.text = @"";
}

-(void)alertTextFieldDidChange:(UITextField*)textfield
{
    _userid = textfield.text;
    
    NSString *tempFileName = [NSString stringWithFormat:@"%@.csv",_userid];
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *tempFile = [docsPath stringByAppendingPathComponent:tempFileName];
    NSOutputStream *output = [NSOutputStream outputStreamToFileAtPath:tempFile append:YES];
    _writer = [[CHCSVWriter alloc] initWithOutputStream:output encoding:NSUTF8StringEncoding delimiter:','];


}
#pragma mark - Circle View
#if CircleView
-(void)updateCircleValue
{
    if (!_circleView) {
        return;
    }
    [_circleView setSensorvalue:[thresholdValue floatValue]];
    KeysBtnView *keybtn = (KeysBtnView*)[movedKey lastObject];
    NSArray *containkeys = [keybtn.titleLabel.text componentsSeparatedByString:@" "];
    if ([self isSlightPress]) {
        [_circleView setText:[self uplowerCasingString:containkeys[0]]];
    }
    else
    {
        [_circleView setText:[self uplowerCasingString:containkeys[1]]];
    }
    if (isTouching) {
        [self performSelector:@selector(updateCircleValue) withObject:self afterDelay:0.01];
    }

}
#endif

#pragma mark - Data Calculation
- (IBAction)calibrateValue:(id)sender {
    calibrateValues = currentSensorValue;
}
- (IBAction)tappedNextBtn:(id)sender {
    if (startTime != nil) {
        [WPMLabel setText:[NSString stringWithFormat:@"WPM:%f", ([taskLabel.orignText length] / 5)/[[NSDate date] timeIntervalSinceDate:startTime]*60]];
        int hardPress_num;
        int lightPress_num;
        [_keysStatistic CalculateHardPressesAndLightPresses:&hardPress_num or:&lightPress_num andInput:[taskLabel orignText]];
        NSLog(@"data->hard: %d, Slight: %d",hardPress_num,lightPress_num);
        NSLog(@"%@",[NSString stringWithFormat:@"WPM:%f, error:%0.2f%%",  ([taskLabel.orignText length] / 5)/[[NSDate date] timeIntervalSinceDate:startTime]*60,(float)100*[_errorCalculator LevenshteinDistance:outputText.text andCorrect:[taskLabel orignText]]/(float)MAX([taskLabel orignText].length, outputText.text.length)]);
        
        NSArray *temp=@[[taskLabel orignText],[outputText text],[NSNumber numberWithInt:hardPress_num],[NSNumber numberWithInt:lightPress_num],[NSNumber numberWithFloat:([taskLabel.orignText length] / 5)/[[NSDate date] timeIntervalSinceDate:startTime]*60],[NSNumber numberWithFloat:(float)100*[_errorCalculator LevenshteinDistance:outputText.text andCorrect:[taskLabel orignText]]/(float)MAX([taskLabel orignText].length, outputText.text.length)]];
        
        
        [_writer writeLineOfFields:temp];
    }
    startTime = [NSDate date];
    [taskLabel nextTask];
    [sender setEnabled:false];
    outputText.text = @"";
}
-(void)updateThreshold
{
    
    if (!isTouching) {
        return;
    }
    
    thresholdValue = [self thresholdCheck];
    if (![self isSlightPress]) {
        self.touchModes = HeavyTouch;
    }
    if (isTouching) {
        [self performSelector:@selector(updateThreshold) withObject:self afterDelay:0.01];
    }
}
-(BOOL)isSlightPress
{
    if ([thresholdValue floatValue] < 1 && _touchModes == SlightTouch) {
        return true;
    }
    return false;
}
-(NSNumber*)thresholdCheck
{
    NSMutableArray *percentageArray = [[NSMutableArray alloc]init];
    
    for (int i = 0; i< [calibrateValues count]; i++) {
        [percentageArray addObject:[NSNumber numberWithFloat:fabs([[calibrateValues objectAtIndex:i] floatValue] - [[currentSensorValue objectAtIndex:i] floatValue])/THERSHOLD]];
    }
    return [percentageArray valueForKeyPath:@"@max.floatValue"];
}
-(NSString*)uplowerCasingString:(NSString*)string
{
    if (upperCase) {
        return [string uppercaseString];
    }
    else
    {
        return [string lowercaseString];
    }
}
#pragma mark - Getter & Setter
-(void)setTouchModes:(TouchModes)touchModes
{
    if (_touchModes == SlightTouch && touchModes == HeavyTouch) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    _touchModes = touchModes;
}
-(TouchModes)touchModes
{
    return _touchModes;
}

@end
