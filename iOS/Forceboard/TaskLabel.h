//
//  TaskLabel.h
//  Forceboard
//
//  Created by 修敏傑 on 2015/5/16.
//  Copyright (c) 2015年 jessehsiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskLabel : UILabel
{
    NSArray *taskArray;
    
    
    int currentindex;
}
@property (nonatomic,readonly) NSString *orignText;

-(void)nextTask;
-(void)cleanNext;
-(void)backforwad;
-(void)backToOrigin;
@end
