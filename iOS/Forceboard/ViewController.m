//
//  ViewController.m
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/11.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import "ViewController.h"
#import "KeysBtnView.h"
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
//#define Splitboard 0


@interface ViewController ()
#if CircleView
@property CircleButtonView* circleView;
#endif
@property CalculateErrorRate* errorCalculator;
@property KeyPressStatistic* keysStatistic;
@property NSString* userid;
@property AppDelegate *appDelegate;
@property int totalErrorCount;
@property int preErrorCount;

@end

@implementation ViewController
@synthesize touchModes = _touchModes;
- (void)viewDidLoad {
    [super viewDidLoad];
    movedKey = [[NSMutableArray alloc]init];
    forceData = [[NSMutableArray alloc] init];
    upperCase= false;
    
    [self addSwipeRecognizers];
    
    outputText.delegate = self;
    
    _errorCalculator = [[CalculateErrorRate alloc ]init];
    //key press statistic
    _keysStatistic = [[KeyPressStatistic alloc] init];
    
    
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    [self.appDelegate changeCSVFileName:self];
    
    
    self.totalErrorCount = 0;
    self.preErrorCount = 0;
    
    
    currentTaskNumberText = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 50, 30)];
    [self.view addSubview:currentTaskNumberText];
    currentTaskNumber = 0;
    currentTaskNumberText.text = [NSString stringWithFormat:@"%d",currentTaskNumber];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.appDelegate showAlertToNotifyUser];
    
}
-(void)dealloc
{
    [self.appDelegate.writer closeStream];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Touch Event
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:keyboardView];
    
    if ([keyboardView pointInside:touchLocation withEvent:event]) {
        
        isTouching = true;
//        NSLog(@"Touch start");
        self.touchModes = SlightTouch;
        
        
        for (UIView *view in keyboardView.subviews)
        {
            if ([view isMemberOfClass:[KeysBtnView class]] &&
                CGRectContainsPoint(view.frame, touchLocation) && view!= [movedKey lastObject])
            {
                [movedKey addObject:view];
            }
        }
        
#if CircleView
        if (CGRectContainsPoint(keyboardView.frame, touchLocation)) {
            _circleView = [[CircleButtonView alloc]initWithFrame:CGRectMake(touchLocation.x,touchLocation.y, 100, 100)];
            [self updateCircleValue];
            [self.view addSubview:_circleView];
        }
#endif
        
    }
    
    
    
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (!isTouching) {
        return;
    }
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:keyboardView];
    
    float forcePercentage = (float)touch.force/ (float)touch.maximumPossibleForce;
    
    [forceData addObject:[NSNumber numberWithFloat:forcePercentage]];
    
    
//    NSLog(@"force - %f", touch.force/ touch.maximumPossibleForce);
    
    for (UIView *view in keyboardView.subviews)
    {
        if ([view isMemberOfClass:[KeysBtnView class]] &&
            CGRectContainsPoint(view.frame, touchLocation) && view!= [movedKey lastObject])
        {
            [movedKey addObject:view];
        }
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
        [self restartForNewTouch];
        return;
    }

    
    KeysBtnView *keybtn = (KeysBtnView*)[movedKey lastObject];
    
    
    if (![self isOtherClass]) {
        [self determineTouchType:0.3];
    }
    
    NSArray *containkeys = [keybtn.titleLabel.text componentsSeparatedByString:@" "];
    
    if (self.touchModes == SlightTouch || [containkeys count] == 1) {
        if ([containkeys[0] isEqualToString:@"space"]) {
            outputText.text = [NSString stringWithFormat:@"%@%@",outputText.text,@" "];
            [taskLabel cleanNext];
        }
        else if([containkeys[0] isEqualToString:@"delete"]) {
            if ([outputText.text length] != 0) {
                outputText.text = [outputText.text substringToIndex:[outputText.text length]-1];
                [taskLabel backforwad];
            }
        }
        else
        {
            outputText.text = [NSString stringWithFormat:@"%@%@",outputText.text,[self uplowerCasingString:containkeys[0]]];
            [taskLabel cleanNext];
        }
    }
    else
    {
        outputText.text = [NSString stringWithFormat:@"%@%@",outputText.text,[self uplowerCasingString:containkeys[1]]];
        [taskLabel cleanNext];
    }
    
    [self restartForNewTouch];
    
    
    
    
//    reset view
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

-(void)restartForNewTouch
{
    [movedKey removeAllObjects];
    [forceData removeAllObjects];
    self.touchModes = SlightTouch;
    upperCase = false;
}

-(void)determineTouchType:(float)threshold
{
    float average = 0.0f;
    
    for (int i = 0; i< [forceData count]; i++) {
        average += [[forceData objectAtIndex:i] floatValue];
    }
    average /= (int)[forceData count];
    
    if (average >= threshold) {
//        NSLog(@"heavy");
        self.touchModes = HeavyTouch;
    }
    else{
//        NSLog(@"slight");
        self.touchModes = SlightTouch;
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
    [self countErrorOperation];
}
-(void)countErrorOperation{
    int currentError = [_errorCalculator LevenshteinDistance:outputText.text andCorrect:[[taskLabel orignText] substringToIndex:([outputText.text length] > [[taskLabel orignText] length] ? [[taskLabel orignText] length]:[outputText.text length])]];
//    NSLog(@"\n%@\n%@\n%d vs %d",outputText.text,[[taskLabel orignText] substringToIndex:[outputText.text length]],currentError,self.preErrorCount);
    
    if ( currentError > self.preErrorCount) {
        self.totalErrorCount++;
    }
    
    self.preErrorCount = currentError;
    
}

-(void)handleRightEdgeGesture:(UIScreenEdgePanGestureRecognizer *)swipeGestureRecognizer{
    
    if (swipeGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"Types of Keyboard" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        
        [alertCon addAction:[UIAlertAction actionWithTitle:@"Force" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            ViewController* vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ViewController"];
            [self presentViewController:vc animated:YES completion:nil];
        }]];
        
        [alertCon addAction:[UIAlertAction actionWithTitle:@"QWERTY" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            QWERTYViewController* vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"QWERTYViewController"];
            [self presentViewController:vc animated:YES completion:nil];
            
        }]];
        
        [alertCon addAction:[UIAlertAction actionWithTitle:@"Zoom" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ZoomViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ZoomViewController"];
            [self presentViewController:vc animated:YES completion:nil];
            
        }]];
        
        [alertCon addAction:[UIAlertAction actionWithTitle:@"Split" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SplitViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"SplitViewController"];
            [self presentViewController:vc animated:YES completion:nil];
            
        }]];
        
        
        [alertCon addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [self presentViewController:alertCon animated:true completion:nil];
    }
}


-(void)addSwipeRecognizers
{
//    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
//    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
//    
//    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
//    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
//    
//    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
//    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
//    
//    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
//    swipeDown.direction = UISwipeGestureRecognizerDirectionRight;
//    
//    [outputText addGestureRecognizer:swipeRight];
//    [outputText addGestureRecognizer:swipeLeft];
//    [outputText addGestureRecognizer:swipeUp];
//    [outputText addGestureRecognizer:swipeDown];
    
    
    
    
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
    //self.appDelegate.calibrateValues = self.appDelegate.currentSensorValue;
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
        
        
        NSArray *temp=@[[taskLabel orignText],[outputText text],[NSNumber numberWithInt:hardPress_num],[NSNumber numberWithInt:lightPress_num],[NSNumber numberWithFloat:([taskLabel.orignText length] / 5.0f)/[[NSDate date] timeIntervalSinceDate:startTime]*60],[NSNumber numberWithFloat:outputText.text.length], [NSNumber numberWithInt:self.totalErrorCount], [NSNumber numberWithInt:hardError], [NSNumber numberWithInt:softError]];
        
        
        [self.appDelegate.writer writeLineOfFields:temp];
    }
    startTime = [NSDate date];
    [taskLabel nextTask];
    [sender setEnabled:false];
    outputText.text = @"";
    self.totalErrorCount = 0;
    self.preErrorCount = 0;
    
    
    currentTaskNumber++;
    currentTaskNumberText.text = [NSString stringWithFormat:@"%d",currentTaskNumber];
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


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [outputText resignFirstResponder];
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
