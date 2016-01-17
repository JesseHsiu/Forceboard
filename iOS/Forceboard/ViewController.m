//
//  ViewController.m
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/11.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import "ViewController.h"
#import "KeysBtnView.h"
#import "JSONKit.h"
#import "KeyPressStatistic.h"
#import "SplitViewController.h"
#import "ZoomViewController.h"
#import "QWERTYViewController.h"
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
//@property CalculateErrorRate* errorCalculator;
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
    
//    _errorCalculator = [[CalculateErrorRate alloc ]init];
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
    
    NSUInteger lenghForErrorCount;
    
    if ([outputText.text length] > [[taskLabel orignText] length]) {
        lenghForErrorCount = [[taskLabel orignText] length];
    }
    else if ([outputText.text length] <= [[taskLabel orignText] length])
    {
        lenghForErrorCount = [outputText.text length];
    }
    
    
    NSLog(@"\n%@\n%@\n%ld\n%d",outputText.text,[[taskLabel orignText] substringToIndex:lenghForErrorCount],(long)[self computeLevenshteinDistanceFrom:outputText.text to:[[taskLabel orignText] substringToIndex:lenghForErrorCount]],self.totalErrorCount);
    
    int currentError = [self computeLevenshteinDistanceFrom:outputText.text to:[[taskLabel orignText] substringToIndex:lenghForErrorCount]];
    
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
    
    UIScreenEdgePanGestureRecognizer *rightEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightEdgeGesture:)];
    rightEdgeGesture.edges = UIRectEdgeRight;
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
        
        
        int hardError = [self computeLevenshteinDistanceFrom:outputText.text to:[taskLabel orignText]];
        int softError = self.totalErrorCount - hardError;
        
        float wpm = ([taskLabel.orignText length] / 5.0f)/[[NSDate date] timeIntervalSinceDate:startTime]*60.0f;
        NSLog(@"data->hard: %d, Slight: %d",hardPress_num,lightPress_num);
        NSLog(@"%@",[NSString stringWithFormat:@"WPM:%f, error:%0.2f%%", wpm,(float)100.0f*hardError/(float)MAX([taskLabel orignText].length, outputText.text.length)]);
        

        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:[taskLabel orignText] forKey:@"original_Text"];
        [dict setObject:[outputText text] forKey:@"user_Text"];
        [dict setObject:[NSNumber numberWithInt:hardPress_num] forKey:@"num_hardPress"];
        [dict setObject:[NSNumber numberWithInt:lightPress_num] forKey:@"num_lightPress"];
        [dict setObject:[NSNumber numberWithFloat:wpm] forKey:@"WPM_value"];
        [dict setObject:[NSNumber numberWithInt:self.totalErrorCount] forKey:@"total_error"];
        
        [dict setObject:[NSNumber numberWithInt:hardError] forKey:@"hard_error"];
        [dict setObject:[NSNumber numberWithInt:softError] forKey:@"soft_error"];
        
        
        
        NSLog(@"%@",[dict JSONString]);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:self.appDelegate.currentFilePath]) {
            JSONDecoder *decoder = [JSONDecoder decoder];
            NSMutableArray *object = [decoder mutableObjectWithData:[[NSFileManager defaultManager] contentsAtPath:self.appDelegate.currentFilePath]];
            
            [object addObject:dict];
            [[object JSONString] writeToFile:self.appDelegate.currentFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        else{
            NSArray *array = @[dict];
            [[array JSONString] writeToFile:self.appDelegate.currentFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        
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





- (int)computeLevenshteinDistanceFrom:(NSString *)source to:(NSString *)target {
    NSUInteger sourceLength = [source length] + 1;
    NSUInteger targetLength = [target length] + 1;
    
    NSMutableArray *cost = [NSMutableArray new];
    NSMutableArray *newCost = [NSMutableArray new];
    
    for (NSUInteger i = 0; i < sourceLength; i++) {
        cost[i] = @(i);
    }
    
    for (NSUInteger j = 1; j < targetLength; j++) {
        newCost[0] = @(j - 1);
        
        for (NSUInteger i = 1; i < sourceLength; i++) {
            NSInteger match = ([source characterAtIndex:i - 1] == [target characterAtIndex:j - 1]) ? 0 : 1;
            NSInteger costReplace = [cost[i - 1] integerValue] + match;
            NSInteger costInsert = [cost[i] integerValue] + 1;
            NSInteger costDelete = [newCost[i - 1] integerValue] + 1;
            newCost[i] = @(MIN(MIN(costInsert, costDelete), costReplace));
        }
        
        NSMutableArray *swap = cost;
        cost = newCost;
        newCost = swap;
    }
    
    return [cost[sourceLength - 1] intValue];
}

@end
