//
//  TaskLabel.m
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/16.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import "TaskLabel.h"

@implementation TaskLabel

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        NSString* filePath = @"phrases2";
        NSString* fileRoot = [[NSBundle mainBundle] pathForResource:filePath ofType:@"txt"];
        // read everything from text
        NSString* fileContents = [NSString stringWithContentsOfFile:fileRoot encoding:NSUTF8StringEncoding error:nil];
        
        // first, separate by new line
        taskArray = [fileContents componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
        
        
        self.minimumScaleFactor = 0.5;
        self.adjustsFontSizeToFitWidth = YES;
        
    }
    return self;

}

-(void)nextTask
{
    int value = arc4random() % 500;
    self.text = [taskArray objectAtIndex:abs(value)*2];
}

@end
