//
//  ViewController.m
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/11.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import "ViewController.h"
#import "KeysBtnView.h"

#define THERSHOLD 2

@interface ViewController ()
@property CircleButtonView* circleView;
@end

@implementation ViewController
@synthesize sensor;
- (void)viewDidLoad {
    [super viewDidLoad];
    sensor = [[SerialGATT alloc] init];
    [sensor setup];
    sensor.delegate = self;
    
    discoveredBLEs = [[NSMutableArray alloc]init];
    movedKey = [[NSMutableArray alloc]init];
    
    upperCase= false;
    
    calibrateValues = [[NSArray alloc]initWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:0.0f] ,nil];

    
    //Swipe Recong
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) serialGATTCharValueUpdated: (NSString *)UUID value: (NSData *)data
{
    NSString *value = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    gonnaSetSensorValue = [value componentsSeparatedByString:@"/"];
    [self performSelector:@selector(changecurrentValue) withObject:nil afterDelay:0.02];
}
-(void)changecurrentValue
{
    currentSensorValue = gonnaSetSensorValue;
}

- (void) setConnect
{
}
- (void) setDisconnect
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
        //NSData *data = [MsgToArduino.text dataUsingEncoding:[NSString defaultCStringEncoding]];
        [sensor write:sensor.activePeripheral data:data];
    }

}


#pragma mark - Touch Event
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[KeysBtnView class]] &&
            CGRectContainsPoint(view.frame, touchLocation) && view!= [movedKey lastObject])
        {
            NSLog(@"Start -> %@",((KeysBtnView*)view).titleLabel.text);
            [movedKey addObject:view];
        }
    }
    
    if (CGRectContainsPoint(keyboardView.frame, touchLocation)) {
        _circleView = [[CircleButtonView alloc]initWithFrame:CGRectMake(touchLocation.x,touchLocation.y, 100, 100)];
        [self updateCircleValue];
        [self.view addSubview:_circleView];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[KeysBtnView class]] &&
            CGRectContainsPoint(view.frame, touchLocation) && view!= [movedKey lastObject])
        {
            NSLog(@"Change to key -> %@",((KeysBtnView*)view).titleLabel.text);
            [movedKey addObject:view];
        }
    }
    
    
    if (CGRectContainsPoint(keyboardView.frame, touchLocation)) {
        
        if (!_circleView) {
            _circleView = [[CircleButtonView alloc]initWithFrame:CGRectMake(touchLocation.x,touchLocation.y, 100, 100)];
            [self.view addSubview:_circleView];
        }
        else
        {
            [_circleView setFrame:CGRectMake(touchLocation.x - 25,touchLocation.y - 70, _circleView.bounds.size.width, _circleView.bounds.size.height)];
        }

        [_circleView setAlpha:1.0f];
        [self updateCircleValue];
    }
    else
    {
        [_circleView setAlpha:0.0f];
    }
    
    
    

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_circleView removeFromSuperview];
    _circleView = nil;
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[KeysBtnView class]] &&
            CGRectContainsPoint(view.frame, touchLocation) && view!= [movedKey lastObject])
        {
            [movedKey addObject:view];
        }
    }
    
    if ([movedKey count] == 0) {
        return;
    }
    KeysBtnView *keybtn = (KeysBtnView*)[movedKey lastObject];
    NSArray *containkeys = [keybtn.titleLabel.text componentsSeparatedByString:@"/"];
//    calibrateValues
    bool overthreshold = false;
    
    for (int i =0 ; i<[currentSensorValue count]; i++) {
        if ([[currentSensorValue objectAtIndex:i] floatValue] > [[calibrateValues objectAtIndex:i] floatValue] * THERSHOLD && [[currentSensorValue objectAtIndex:i] floatValue] > 200) {
            overthreshold = true;
        }
    }
    
    if (!overthreshold) {
        NSLog(@"%@",containkeys[0]);
        outputText.text = [NSString stringWithFormat:@"%@%@",outputText.text,[self uplowerCasingString:containkeys[0]]];
    }
    else
    {
        NSLog(@"%@",containkeys[1]);
        outputText.text = [NSString stringWithFormat:@"%@%@",outputText.text,[self uplowerCasingString:containkeys[1]]];
    }
    upperCase = false;
    [movedKey removeAllObjects];
    
    
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[KeysBtnView class]])
        {
            [(KeysBtnView*)view setTitle:[[(KeysBtnView*)view currentTitle] lowercaseString] forState:UIControlStateNormal];
        }
    }
    
    
    [self performSelector:@selector(calibrateValue:) withObject:self afterDelay:0.1];
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
#pragma mark - SwipeGesture
-(void)handleSwipeGesture:(UISwipeGestureRecognizer *)swipeGestureRecognizer{
    [_circleView removeFromSuperview];
    _circleView = nil;
    switch (swipeGestureRecognizer.direction) {
        case UISwipeGestureRecognizerDirectionRight:
            outputText.text = [NSString stringWithFormat:@"%@%@",outputText.text,@" "];
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            if ([outputText.text length] == 0) {
                return;
            }
            outputText.text = [outputText.text substringToIndex:[outputText.text length]-1];
            break;
        case UISwipeGestureRecognizerDirectionUp:
            upperCase = true;
            for (UIView *view in self.view.subviews)
            {
                if ([view isKindOfClass:[KeysBtnView class]])
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
- (IBAction)ClearUILabel:(id)sender {
    outputText.text = @"";
}

-(void)updateCircleValue
{
    if (!_circleView) {
        return;
    }
    float avgValue = 0.0f;
    for (int i = 0; i< [gonnaSetSensorValue count]; i++) {
        avgValue += [[gonnaSetSensorValue objectAtIndex:i] floatValue]/[gonnaSetSensorValue count];
    }
    
    [_circleView setSensorvalue:avgValue];

}


- (IBAction)calibrateValue:(id)sender {
    calibrateValues = gonnaSetSensorValue;
//    bool shouldcalibrate = true;
//    for (int i = 0 ; i< [calibrateValues count]; i++) {
//        if ([[calibrateValues objectAtIndex:i] floatValue] * 1.5 < [[gonnaSetSensorValue objectAtIndex:i] floatValue]) {
//            shouldcalibrate = false;
//        }
//    }
//    if (shouldcalibrate) {
//        
//    }
    
}

@end
