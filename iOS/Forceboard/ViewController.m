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
#import "SplitViewController.h"
#import "ZoomViewController.h"
#import "QWERTYViewController.h"
#import <CHCSVParser.h>
#import "AppDelegate.h"


#define THERSHOLD 200
//use CircleView
#define CircleView 0
#define QWERTYBoard 0


@interface ViewController ()
#if CircleView
@property CircleButtonView* circleView;
#endif
@property CalculateErrorRate* errorCalculator;
@property KeyPressStatistic* keysStatistic;
//@property CHCSVWriter *writer;
@property NSString* userid;
@property AppDelegate *appDelegate;
@property int totalErrorCount;
@property int preErrorCount;

@end

@implementation ViewController
//@synthesize sensor;
@synthesize touchModes = _touchModes;
- (void)viewDidLoad {
    [super viewDidLoad];
    movedKey = [[NSMutableArray alloc]init];
    upperCase= false;
    
    [self addSwipeRecognizers];
    
    outputText.delegate = self;
//    outputText.minimumScaleFactor = 0.5;
//    outputText.adjustsFontSizeToFitWidth = YES;
    
//    zoomboard
//        CGAffineTransform transform = CGAffineTransformMakeScale(1.5, 1.5);
        // you can implement any int/float value in context of what scale you want to zoom in or out
//        keyboardView.transform = transform;
    
    _errorCalculator = [[CalculateErrorRate alloc ]init];
    //key press statistic
    _keysStatistic = [[KeyPressStatistic alloc] init];
    
    
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    
    
    if ([self.appDelegate isBleConnected]) {
        [searchBtn removeFromSuperview];
    }
    self.totalErrorCount = 0;
    self.preErrorCount = 0;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.appDelegate showAlertToNotifyUser];
    
//    if ([self isKindOfClass:[ViewController class]]) {
//        [self.appDelegate showAlertToNotifyUser];
//    }
    
}
-(void)dealloc
{
    [self.appDelegate.writer closeStream];
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
    
    //need to call delegate to start searching
    [self.appDelegate startScanningBLE];
}

#pragma mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.appDelegate.discoveredBLEs count];

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = ((CBPeripheral *)[self.appDelegate.discoveredBLEs objectAtIndex:indexPath.row]).name;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    self.appDelegate.bleSerial.activePeripheral = [self.appDelegate.discoveredBLEs objectAtIndex:row];
    [self.appDelegate.bleSerial connect:self.appDelegate.bleSerial.activePeripheral];
    [self.appDelegate stopScanning];
    
    //UI stuff
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [tableview setAlpha:0];
    [searchBtn setAlpha:0];
    [UIView commitAnimations];
}

#pragma mark - Touch Event
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    isTouching = true;
    self.touchModes = SlightTouch;
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:keyboardView];
    
    for (UIView *view in keyboardView.subviews)
    {
        if ([view isMemberOfClass:[KeysBtnView class]] &&
            CGRectContainsPoint(view.frame, touchLocation) && view!= [movedKey lastObject])
        {
            [movedKey addObject:view];
        }
    }
    if (![self isOtherClass]) {
        [self updateThreshold];
    }
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
    CGPoint touchLocation = [touch locationInView:keyboardView];
    
    for (UIView *view in keyboardView.subviews)
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
    CGPoint touchLocation = [touch locationInView:keyboardView];
    for (UIView *view in keyboardView.subviews)
    {
        if ([view isMemberOfClass:[KeysBtnView class]] &&
            CGRectContainsPoint(view.frame, touchLocation) && view!= [movedKey lastObject])
        {
            [movedKey addObject:view];
        }
    }
    
    if ([movedKey count] == 0) {
        [movedKey removeAllObjects];
        return;
    }

    [taskLabel cleanNext];
    KeysBtnView *keybtn = (KeysBtnView*)[movedKey lastObject];


    NSArray *containkeys = [keybtn.titleLabel.text componentsSeparatedByString:@" "];
    
    if (self.touchModes == SlightTouch || [containkeys count] == 1) {
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
    
    
    for (UIView *view in keyboardView.subviews)
    {
        if ([view isMemberOfClass:[KeysBtnView class]])
        {
            [(KeysBtnView*)view setTitle:[[(KeysBtnView*)view currentTitle] lowercaseString] forState:UIControlStateNormal];
        }
    }
    
    
    if ([taskLabel.orignText length]<= [outputText.text length]) {
        [nextTaskBtn setEnabled:YES];
    }
    
    
    NSRange range = NSMakeRange(outputText.text.length - 1, 1);
    [outputText scrollRangeToVisible:range];
    
    [self countErrorOperation];
    
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
            for (UIView *view in keyboardView.subviews)
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
    
    if([self isKindOfClass:[SplitViewController class]])
    {
        [self performSelector:@selector(adjustPosition) withObject:self afterDelay:0.005];
    }
    
    
    [self countErrorOperation];
}
-(void)countErrorOperation{
    int currentError = [_errorCalculator LevenshteinDistance:outputText.text andCorrect:[[taskLabel orignText] substringToIndex:[outputText.text length]]];
//    NSLog(@"\n%@\n%@\n%d vs %d",outputText.text,[[taskLabel orignText] substringToIndex:[outputText.text length]],currentError,self.preErrorCount);
    
    if ( currentError > self.preErrorCount) {
        self.totalErrorCount++;
    }
    
    self.preErrorCount = currentError;
    
}

-(void)handleRightEdgeGesture:(UIScreenEdgePanGestureRecognizer *)swipeGestureRecognizer{
    
    if (swipeGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Types of Keyboard" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"Force",@"QWERTY",@"Zoom", @"Split", nil];
        [actionSheet showInView:self.view];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    
    switch (buttonIndex) {
        case 0:{
            ViewController* vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ViewController"];
            [self presentViewController:vc animated:YES completion:nil];
            break;
        }
        case 1:{
            QWERTYViewController* vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"QWERTYViewController"];
            [self presentViewController:vc animated:YES completion:nil];
            break;
        }
        case 2:{
            ZoomViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ZoomViewController"];
            [self presentViewController:vc animated:YES completion:nil];
            break;
        }
        case 3:{
            SplitViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"SplitViewController"];
            [self presentViewController:vc animated:YES completion:nil];
            
            break;
        }
            
        default:
            break;
    }
    
    
    
//    [self presentViewController:<#(UIViewController *)#> animated:<#(BOOL)#> completion:<#^(void)completion#>]
//    
//    
//    
//    presentViewController:animated:completion:
    
    
    
    NSLog(@"%ld",(long)buttonIndex);
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
    
    
    
    
    UIScreenEdgePanGestureRecognizer *rightEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightEdgeGesture:)];
    rightEdgeGesture.edges = UIRectEdgeRight;
//    rightEdgeGesture.delegate = self;
    [self.view addGestureRecognizer:rightEdgeGesture];
}

#pragma mark - Button Action
- (IBAction)ClearUILabel:(id)sender {
    [taskLabel backToOrigin];
    outputText.text = @"";
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
    if ([self isSlightPress] || [containkeys count] == 1) {
        [_circleView setText:[self uplowerCasingString:containkeys[0]]];
    }
    else
    {
        [_circleView setText:[self uplowerCasingString:containkeys[1]]];
    }

    [_circleView setText:[self uplowerCasingString:keybtn.titleLabel.text]];

    if (isTouching) {
        [self performSelector:@selector(updateCircleValue) withObject:self afterDelay:0.01];
    }
    

}
#endif

#pragma mark - Data Calculation
- (IBAction)calibrateValue:(id)sender {
    self.appDelegate.calibrateValues = self.appDelegate.currentSensorValue;
}
- (IBAction)tappedNextBtn:(id)sender {
    if (startTime != nil) {
        [WPMLabel setText:[NSString stringWithFormat:@"WPM:%f", ([taskLabel.orignText length] / 5)/[[NSDate date] timeIntervalSinceDate:startTime]*60]];
        int hardPress_num;
        int lightPress_num;
        [_keysStatistic CalculateHardPressesAndLightPresses:&hardPress_num or:&lightPress_num andInput:[taskLabel orignText]];
        NSLog(@"data->hard: %d, Slight: %d",hardPress_num,lightPress_num);
        NSLog(@"%@",[NSString stringWithFormat:@"WPM:%f, error:%0.2f%%",  ([taskLabel.orignText length] / 5)/[[NSDate date] timeIntervalSinceDate:startTime]*60,(float)100*[_errorCalculator LevenshteinDistance:outputText.text andCorrect:[taskLabel orignText]]/(float)MAX([taskLabel orignText].length, outputText.text.length)]);
        
        
        //[NSNumber numberWithFloat:(float)100*[_errorCalculator LevenshteinDistance:outputText.text andCorrect:[taskLabel orignText]]/(float)MAX([taskLabel orignText].length, outputText.text.length)]
        
        int hardError = [_errorCalculator LevenshteinDistance:outputText.text andCorrect:[taskLabel orignText]];
        int softError = self.totalErrorCount - hardError;
        
        
        NSArray *temp=@[[taskLabel orignText],[outputText text],[NSNumber numberWithInt:hardPress_num],[NSNumber numberWithInt:lightPress_num],[NSNumber numberWithFloat:([taskLabel.orignText length] / 5)/[[NSDate date] timeIntervalSinceDate:startTime]*60],[NSNumber numberWithFloat:outputText.text.length], [NSNumber numberWithInt:self.totalErrorCount], [NSNumber numberWithInt:hardError], [NSNumber numberWithInt:softError]];
        
        
        [self.appDelegate.writer writeLineOfFields:temp];
    }
    startTime = [NSDate date];
    [taskLabel nextTask];
    [sender setEnabled:false];
    outputText.text = @"";
    self.totalErrorCount = 0;
    self.preErrorCount = 0;
    
    if([self isKindOfClass:[SplitViewController class]])
    {
        [self performSelector:@selector(adjustPosition) withObject:self afterDelay:0.005];
    }
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
    
    for (int i = 0; i< [self.appDelegate.calibrateValues count]; i++) {
        [percentageArray addObject:[NSNumber numberWithFloat:fabs([[self.appDelegate.calibrateValues objectAtIndex:i] floatValue] - [[self.appDelegate.currentSensorValue objectAtIndex:i] floatValue])/THERSHOLD]];
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

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [outputText resignFirstResponder];
    if([self isKindOfClass:[SplitViewController class]])
    {
        [self performSelector:@selector(adjustPosition) withObject:self afterDelay:0.005];
    }
}

-(BOOL)isOtherClass
{
    if ([self isKindOfClass:[SplitViewController class]] || [self isKindOfClass:[ZoomViewController class]] || [self isKindOfClass:[QWERTYViewController class]]) {
        return YES;
    }
    else
    {
        return NO;
    }

}

@end
