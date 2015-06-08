//
//  TaskLabel.m
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/16.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import "TaskLabel.h"

@implementation TaskLabel
@synthesize orignText;
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
        
        
//        self.minimumScaleFactor = 0.5;
//        self.adjustsFontSizeToFitWidth = YES;
        
    }
    return self;

}

-(void)backToOrigin
{
    currentindex = 0;
    self.text = orignText;
    
    [self replaceSpaces];
    [self addSpaces];
    [self updateAttributed];

}


-(void)nextTask
{
    int value = arc4random() % 500;
    self.text = [taskArray objectAtIndex:abs(value)*2];
    orignText = self.text;
    
    
    currentindex = 0;
    
    [self replaceSpaces];
    [self addSpaces];
    [self updateAttributed];
}

-(void)cleanNext
{
    if ([orignText length] == currentindex) {
        return;
    }
    else
    {
        currentindex++;
        self.text = [orignText substringFromIndex:currentindex];

        [self replaceSpaces];
        [self addSpaces];
        [self updateAttributed];
    }
    
    
//    NSMutableAttributedString *attDescribe = 
    
    
//    NSAttributedString *attString = [[NSAttributedString alloc]initWithString:self.text];
    
}

-(void)backforwad
{
    currentindex--;
    self.text = [orignText substringFromIndex:currentindex];

    [self replaceSpaces];
    [self addSpaces];
    [self updateAttributed];
}
-(void)replaceSpaces
{
    self.text = [self.text stringByReplacingOccurrencesOfString:@" "
                                         withString:@"_"];
}

-(void)addSpaces
{
    self.text = [NSString stringWithFormat:@"          %@          ",self.text];
}

-(void)updateAttributed
{
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]initWithString:self.text];
    [attString addAttribute: NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(10,1)];
    
    [self setAttributedText:attString];
}

@end
